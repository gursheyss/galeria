import { requireNativeView } from 'expo'

import { useContext } from 'react'
import { Image } from 'react-native'
import { NativeModulesProxy } from 'expo-modules-core'
import type { SFSymbol } from 'sf-symbols-typescript'
import { GaleriaContext } from './context'
import {
  GaleriaIndexChangedEvent,
  GaleriaRightNavItemPressedEvent,
  GaleriaViewProps,
} from './Galeria.types'

const NativeImage = requireNativeView<
  GaleriaViewProps & {
    urls?: string[]
    closeIconName?: SFSymbol
    rightNavItemIconName?: SFSymbol
    rightNavItemSecondaryIconName?: SFSymbol
    rightNavItemSecondaryDestructive?: boolean
    mediaTypes?: string[]
    theme: 'dark' | 'light'
    onIndexChange?: (event: GaleriaIndexChangedEvent) => void
    onPressRightNavItemIcon?: (event: GaleriaRightNavItemPressedEvent) => void
    onPressRightNavItemSecondaryIcon?: (
      event: GaleriaRightNavItemPressedEvent
    ) => void
    hideBlurOverlay?: boolean
    hidePageIndicators?: boolean
  }
>('Galeria')

const noop = () => {}
const galeriaModule = NativeModulesProxy.Galeria

const Galeria = Object.assign(
  function Galeria({
    children,
    closeIconName,
    rightNavItemIconName,
    rightNavItemSecondaryIconName,
    rightNavItemSecondaryDestructive,
    onPressRightNavItemIcon,
    onPressRightNavItemSecondaryIcon,
    urls,
    theme = 'dark',
    ids,
    hideBlurOverlay = false,
    hidePageIndicators = false,
    mediaTypes,
  }: {
    children: React.ReactNode
  } & Partial<
    Pick<
      GaleriaContext,
      | 'theme'
      | 'ids'
      | 'urls'
      | 'closeIconName'
      | 'rightNavItemIconName'
      | 'rightNavItemSecondaryIconName'
      | 'rightNavItemSecondaryDestructive'
      | 'onPressRightNavItemIcon'
      | 'onPressRightNavItemSecondaryIcon'
      | 'hideBlurOverlay'
      | 'hidePageIndicators'
      | 'mediaTypes'
    >
  >) {
    return (
      <GaleriaContext.Provider
        value={{
          closeIconName,
          rightNavItemIconName,
          rightNavItemSecondaryIconName,
          rightNavItemSecondaryDestructive:
            rightNavItemSecondaryDestructive ?? false,
          onPressRightNavItemIcon,
          onPressRightNavItemSecondaryIcon,
          urls,
          theme,
          initialIndex: 0,
          open: false,
          src: '',
          setOpen: noop,
          ids,
          hideBlurOverlay,
          hidePageIndicators,
          mediaTypes,
        }}
      >
        {children}
      </GaleriaContext.Provider>
    )
  },
  {
    Image(props: GaleriaViewProps) {
      const {
        theme,
        urls,
        initialIndex,
        closeIconName,
        rightNavItemIconName,
        rightNavItemSecondaryIconName,
        rightNavItemSecondaryDestructive,
        onPressRightNavItemIcon,
        onPressRightNavItemSecondaryIcon,
        hideBlurOverlay,
        hidePageIndicators,
        mediaTypes,
      } = useContext(GaleriaContext)
      return (
        <NativeImage
          onIndexChange={props.onIndexChange}
          closeIconName={closeIconName}
          rightNavItemIconName={
            props.rightNavItemIconName ?? rightNavItemIconName
          }
          onPressRightNavItemIcon={
            props.onPressRightNavItemIcon ?? onPressRightNavItemIcon
          }
          rightNavItemSecondaryIconName={
            props.rightNavItemSecondaryIconName ?? rightNavItemSecondaryIconName
          }
          rightNavItemSecondaryDestructive={
            props.rightNavItemSecondaryDestructive ??
            rightNavItemSecondaryDestructive ??
            false
          }
          onPressRightNavItemSecondaryIcon={
            props.onPressRightNavItemSecondaryIcon ??
            onPressRightNavItemSecondaryIcon
          }
          theme={theme}
          hideBlurOverlay={props.hideBlurOverlay ?? hideBlurOverlay}
          hidePageIndicators={props.hidePageIndicators ?? hidePageIndicators}
          mediaTypes={mediaTypes}
          urls={urls?.map((url) => {
            if (typeof url === 'string') {
              return url
            }

            return Image.resolveAssetSource(url).uri
          })}
          index={initialIndex}
          {...props}
        />
      )
    },
    Popup: (() => null) as React.FC<{
      disableTransition?: 'web'
    }>,
    close() {
      galeriaModule?.close?.()
    },
  },
)

export default Galeria
