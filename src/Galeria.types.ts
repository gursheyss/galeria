import type { motion } from 'framer-motion'
import type { ComponentProps } from 'react'
import type { NativeSyntheticEvent } from 'react-native'
import { ViewStyle } from 'react-native'
import type { SFSymbol } from 'sf-symbols-typescript'

export type ChangeEventPayload = {
  value: string
}

type GaleriaIndexChangedPayload = {
  currentIndex: number
}

export type GaleriaIndexChangedEvent =
  NativeSyntheticEvent<GaleriaIndexChangedPayload>

type GaleriaRightNavItemPressedPayload = {
  index: number
}

export type GaleriaRightNavItemPressedEvent =
  NativeSyntheticEvent<GaleriaRightNavItemPressedPayload>

export interface GaleriaViewProps {
  index?: number
  id?: string
  children: React.ReactElement
  closeIconName?: SFSymbol
  rightNavItemIconName?: SFSymbol
  rightNavItemSecondaryIconName?: SFSymbol
  rightNavItemSecondaryDestructive?: boolean
  __web?: ComponentProps<(typeof motion)['div']>
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
