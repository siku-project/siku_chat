import type { CommandDef } from '@/utils/command'

export const MOCK_COMMANDS: CommandDef[] = [
  {
    name: 'me',
    description: 'Décrit une action de votre personnage.',
    params: [{ name: 'action', description: 'L’action réalisée par votre personnage.' }],
  },
  {
    name: 'do',
    description: 'Décrit l’environnement ou une situation autour de vous.',
    params: [{ name: 'description', description: 'La situation ou l’élément à décrire.' }],
  },
  {
    name: 'ooc',
    description: 'Parler hors-RP (out of character).',
    params: [{ name: 'message', description: 'Votre message hors-RP.' }],
  },
  {
    name: 'pay',
    description: 'Donner de l’argent à un joueur proche.',
    params: [
      { name: 'joueur', description: 'Le joueur à qui donner l’argent.' },
      { name: 'montant', description: 'La somme à transférer.' },
    ],
  },
  {
    name: 'tp',
    description: 'Se téléporter vers un joueur.',
    params: [{ name: 'joueur', description: 'Le joueur cible.' }],
    staff: true,
  },
  {
    name: 'heal',
    description: 'Soigner un joueur, ou vous-même.',
    params: [
      {
        name: 'joueur',
        description: 'Le joueur à soigner. Vous-même si laissé vide.',
        optional: true,
      },
    ],
    staff: true,
  },
  {
    name: 'kick',
    description: 'Expulser un joueur du serveur.',
    params: [
      { name: 'joueur', description: 'Le joueur à expulser.' },
      { name: 'raison', description: 'La raison de l’expulsion.', optional: true },
    ],
    staff: true,
  },
  {
    name: 'ban',
    description: 'Bannir un joueur du serveur.',
    params: [
      { name: 'joueur', description: 'Le joueur à bannir.' },
      { name: 'durée', description: 'Durée du ban (ex : 7d, perm).' },
      { name: 'raison', description: 'La raison du bannissement.', optional: true },
    ],
    staff: true,
  },
  {
    name: 'announce',
    description: 'Envoyer une annonce à tout le serveur.',
    params: [{ name: 'message', description: 'Le contenu de l’annonce.' }],
    staff: true,
  },
  {
    name: 'staffchat',
    description: 'Basculer dans le canal staff.',
    params: [],
    staff: true,
  },
]
