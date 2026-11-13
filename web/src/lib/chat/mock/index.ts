import { game } from '../bridge'
import { parseCommand } from '../commands'
import { store } from '../store.svelte'
import type { ChatMessageInput, CommandDef } from '../types'

export const LOCAL_NAME = 'Ethan Brooks'
export const LOCAL_RANK = 'admin'

const at = (hour: number, minute: number): number => {
  const date = new Date()

  date.setHours(hour, minute, 0, 0)

  return date.getTime()
}

export const MOCK_COMMANDS: CommandDef[] = [
  {
    name: 'me',
    description: 'Décrit une action de ton personnage.',
    params: [{ name: 'action', description: 'L’action réalisée.', optional: false }],
  },
  {
    name: 'do',
    description: 'Décrit l’environnement ou une situation autour de toi.',
    params: [{ name: 'description', description: 'La situation à décrire.', optional: false }],
  },
  {
    name: 'ooc',
    description: 'Parler hors-RP.',
    params: [{ name: 'message', description: 'Ton message hors-RP.', optional: false }],
  },
  {
    name: 'pay',
    description: 'Donner de l’argent à un joueur proche.',
    params: [
      { name: 'joueur', description: 'Le joueur à qui donner l’argent.', optional: false },
      { name: 'montant', description: 'La somme à transférer.', optional: false },
    ],
  },
  {
    name: 'tp',
    description: 'Se téléporter vers un joueur.',
    params: [{ name: 'joueur', description: 'Le joueur cible.', optional: false }],
  },
  {
    name: 'heal',
    description: 'Soigner un joueur, ou toi-même.',
    params: [{ name: 'joueur', description: 'Le joueur à soigner, toi si vide.', optional: true }],
  },
  {
    name: 'kick',
    description: 'Expulser un joueur du serveur.',
    params: [
      { name: 'joueur', description: 'Le joueur à expulser.', optional: false },
      { name: 'raison', description: 'La raison de l’expulsion.', optional: true },
    ],
  },
  {
    name: 'announce',
    description: 'Envoyer une annonce à tout le serveur.',
    params: [{ name: 'message', description: 'Le contenu de l’annonce.', optional: false }],
  },
  { name: 'staffchat', description: 'Rejoindre le canal staff.', params: [] },
]

export const DEMO_MESSAGES: ChatMessageInput[] = [
  { type: 'system', timestamp: at(21, 14), text: 'Bienvenue sur SIKU.' },
  { type: 'player', timestamp: at(21, 15), author: 'Léa Marchand', text: 'Salut tout le monde.' },
  {
    type: 'player',
    timestamp: at(21, 15),
    author: 'Tom Rivera',
    text: 'Quelqu’un de dispo pour un taxi vers l’aéroport ?',
  },
  { type: 'info', timestamp: at(21, 16), text: 'Noah Bennett a rejoint la ville.' },
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
    type: 'success',
    timestamp: at(21, 18),
    text: 'Virement de 1 250 $ reçu de Camille Laurent.',
  },
  {
    type: 'player',
    timestamp: at(21, 19),
    author: 'Maxime Dubois',
    text: 'Salut la compagnie, ça roule ?',
  },
  {
    type: 'warning',
    timestamp: at(21, 19),
    text: 'Le serveur redémarre dans 30 minutes.',
  },
  {
    type: 'server',
    timestamp: at(21, 19),
    text: 'Événement ce soir à 21 h 30 sur la place centrale.',
  },
  {
    type: 'player',
    timestamp: at(21, 20),
    author: 'Tom Rivera',
    text: 'Toujours, on part sur un tour de ville tout à l’heure.',
  },
  {
    type: 'system',
    channel: 'staff',
    timestamp: at(21, 12),
    text: 'Canal staff, visible seulement par le staff.',
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
    text: 'Reçu, je le mets en zone iso le temps de vérifier.',
  },
]

const INCOMING = [
  { author: 'Léa Marchand', text: 'Salut, quelqu’un dans le coin ?' },
  { author: 'Tom Rivera', text: 'Je passe au marché, besoin de rien ?' },
  { author: 'Noah Bennett', text: 'Rendez-vous au spot dans 5 minutes.' },
  { author: 'Camille Laurent', text: 'J’arrive, deux minutes !' },
  { type: 'server', text: 'Redémarrage du serveur dans 10 minutes.' },
]

let incomingIndex = 0

/** One more public message from another player, as the server would push it. */
export const simulateIncoming = (): void => {
  const entry = INCOMING[incomingIndex % INCOMING.length]

  incomingIndex += 1

  if (entry) {
    store.addMessage({ type: entry.type ?? 'player', author: entry.author, text: entry.text })
  }
}

/** Replaces the calls to the game with local echoes, so the playground answers like a server would. */
const echoLocally = (): void => {
  game.close = async () => {
    store.hide()
    return true
  }

  game.sendMessage = async (text: string) => {
    store.addMessage({ type: 'player', author: LOCAL_NAME, text })
    return true
  }

  game.sendStaffMessage = async (text: string) => {
    store.addMessage({
      type: 'player',
      channel: 'staff',
      author: LOCAL_NAME,
      rank: LOCAL_RANK,
      text,
    })
    return true
  }

  game.command = async (raw: string) => {
    const { name } = parseCommand(`${store.config.commandPrefix}${raw}`, store.config.commandPrefix)

    if (name === 'staffchat') {
      store.setMode('staff')
      store.show()
    } else {
      store.addMessage({ type: 'system', channel: store.mode, text: `Commande envoyée : ${raw}` })
    }

    return true
  }
}

/** What the game would have sent before the chat opens, for the browser playground. */
export const loadMocks = (): void => {
  echoLocally()

  for (const command of MOCK_COMMANDS) {
    store.registerCommand(command)
  }

  if (store.messages.length === 0) {
    store.replayMessages(DEMO_MESSAGES)
  }

  store.show()
}
