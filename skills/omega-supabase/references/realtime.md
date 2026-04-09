# Real-time — Subscriptions Supabase

Doc ufficiale: https://supabase.com/docs

## Subscription a tabella (Client Component)

```typescript
'use client'
import { createClient } from '@/lib/supabase/client'
import { useEffect, useState } from 'react'

export function LiveOrders() {
  const [orders, setOrders] = useState<Order[]>([])
  const supabase = createClient()

  useEffect(() => {
    // Carica inizialmente
    supabase.from('ordini').select('*').then(({ data }) => {
      if (data) setOrders(data)
    })

    // Subscribe agli aggiornamenti
    const channel = supabase
      .channel('ordini-live')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'ordini' },
        (payload) => {
          if (payload.eventType === 'INSERT') {
            setOrders(prev => [...prev, payload.new as Order])
          }
          if (payload.eventType === 'UPDATE') {
            setOrders(prev => prev.map(o =>
              o.id === payload.new.id ? payload.new as Order : o
            ))
          }
          if (payload.eventType === 'DELETE') {
            setOrders(prev => prev.filter(o => o.id !== payload.old.id))
          }
        }
      )
      .subscribe()

    return () => { supabase.removeChannel(channel) }
  }, [])

  return <div>{/* render orders */}</div>
}
```

**Nota:** Real-time funziona con RLS attiva — ogni utente riceve solo gli aggiornamenti che può vedere.

**Attenzione:** Abilitare real-time solo dove necessario — consuma risorse significative.
