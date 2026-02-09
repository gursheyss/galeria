import type { ReactElement, ReactNode } from 'react'
import type { NativeSyntheticEvent, ViewStyle } from 'react-native'

type GaleriaTheme = 'dark' | 'light'

type GaleriaIndexChangedPayload = {
  currentIndex: number
}

type GaleriaRightNavItemPressedPayload = {
  index: number
}

export type GaleriaIndexChangedEvent =
  NativeSyntheticEvent<GaleriaIndexChangedPayload>

export type GaleriaRightNavItemPressedEvent =
  NativeSyntheticEvent<GaleriaRightNavItemPressedPayload>

export interface GaleriaViewProps {
  index?: number
  id?: string
  children: ReactElement
  closeIconName?: string
  rightNavItemIconName?: string
  rightNavItemSecondaryIconName?: string
  rightNavItemSecondaryDestructive?: boolean
  style?: ViewStyle
  dynamicAspectRatio?: boolean
  edgeToEdge?: boolean
  onIndexChange?: (event: GaleriaIndexChangedEvent) => void
  onPressRightNavItemIcon?: (event: GaleriaRightNavItemPressedEvent) => void
  onPressRightNavItemSecondaryIcon?: (
    event: GaleriaRightNavItemPressedEvent
  ) => void
  hideBlurOverlay?: boolean
  hidePageIndicators?: boolean
}

export interface GaleriaRootProps {
  children: ReactNode
  urls?: string[]
  mediaTypes?: string[]
  ids?: string[]
  theme?: GaleriaTheme
  closeIconName?: string
  rightNavItemIconName?: string
  rightNavItemSecondaryIconName?: string
  rightNavItemSecondaryDestructive?: boolean
  onPressRightNavItemIcon?: (event: GaleriaRightNavItemPressedEvent) => void
  onPressRightNavItemSecondaryIcon?: (
    event: GaleriaRightNavItemPressedEvent
  ) => void
  hideBlurOverlay?: boolean
  hidePageIndicators?: boolean
}

export interface GaleriaPopupProps {
  disableTransition?: 'web'
}

type GaleriaComponent = ((props: GaleriaRootProps) => ReactElement | null) & {
  Image: (props: GaleriaViewProps) => ReactElement | null
  Popup: (props: GaleriaPopupProps) => ReactElement | null
  close: () => void
  setIndex: (index: number) => void
}

export const Galeria: GaleriaComponent
