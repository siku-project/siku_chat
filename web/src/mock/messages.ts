import type { ChatMessageInput } from '@/stores/chat'

export const LOCAL_NAME = 'Ethan Brooks'
export const LOCAL_RANK = 'admin'

const at = (hour: number, minute: number): number => {
  const date = new Date()
  date.setHours(hour, minute, 0, 0)
  return date.getTime()
}

export const DEMO_MESSAGES: ChatMessageInput[] = [
  { type: 'system', timestamp: at(21, 14), text: 'Bienvenue sur SIKU.' },
  {
    type: 'player',
    timestamp: at(21, 15),
    author: 'Léa Marchand',
    text: 'Salut tout le monde.',
  },
  {
    type: 'player',
    timestamp: at(21, 15),
    author: 'Tom Rivera',
    text: 'Quelqu’un de dispo pour un taxi vers l’aéroport ?',
  },
  { type: 'system', timestamp: at(21, 16), text: 'Noah Bennett a rejoint la ville.' },
  {
    type: 'player',
    timestamp: at(21, 17),
    author: 'Noah Bennett',
    text: 'Je suis en route, deux minutes.',
  },
  {
    type: 'player',
    timestamp: at(21, 18),
    author: 'Camille Laurent',
    text: 'Je passe au garage récupérer la voiture.',
  },
  {
    type: 'player',
    timestamp: at(21, 18),
    author: 'Léa Marchand',
    text: 'Quelqu’un connaît un bon concess dans le coin ?',
  },
  { type: 'system', timestamp: at(21, 19), text: 'Maxime Dubois a rejoint la ville.' },
  {
    type: 'player',
    timestamp: at(21, 19),
    author: 'Maxime Dubois',
    text: 'Salut la compagnie, ça roule ?',
  },
  {
    type: 'player',
    timestamp: at(21, 20),
    author: 'Tom Rivera',
    text: 'Toujours, on part sur un tour de ville tout à l’heure.',
  },
  {
    type: 'player',
    timestamp: at(21, 20),
    author: 'Noah Bennett',
    text: 'Je suis chaud, je ramène deux potes.',
  },
  {
    type: 'system',
    channel: 'staff',
    timestamp: at(21, 12),
    text: 'Canal staff — visible uniquement par le staff.',
  },
  {
    type: 'player',
    channel: 'staff',
    timestamp: at(21, 12),
    author: 'Nathan Roche',
    rank: 'owner',
    text: 'On garde un œil sur l’événement de ce soir.',
  },
  {
    type: 'player',
    channel: 'staff',
    timestamp: at(21, 13),
    author: 'Éva Simon',
    rank: 'dev',
    text: 'Patch du garage déployé, à tester quand vous pouvez.',
  },
  {
    type: 'player',
    channel: 'staff',
    timestamp: at(21, 13),
    author: 'Julie Ferrand',
    rank: 'admin',
    text: 'Signalement en cours sur le joueur #42, je regarde.',
  },
  {
    type: 'player',
    channel: 'staff',
    timestamp: at(21, 14),
    author: 'Karim Belaïd',
    rank: 'mod',
    text: 'Reçu, je le mets en zone iso le temps de check.',
  },
]
