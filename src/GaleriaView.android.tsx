import { requireNativeView } from 'expo'

import { useContext } from 'react'
import { Image } from 'react-native'
import { NativeModulesProxy } from 'expo-modules-core'
import {
  controlEdgeToEdgeValues,
  isEdgeToEdge,
} from 'react-native-is-edge-to-edge'
import { GaleriaContext } from './context'
import {
  GaleriaIndexChangedEvent,
  GaleriaRightNavItemPressedEvent,
  GaleriaViewProps,
} from './Galeria.types'

const EDGE_TO_EDGE = isEdgeToEdge()

const NativeImage = requireNativeView<
  GaleriaViewProps & {
    edgeToEdge: boolean
    urls?: string[]
    mediaTypes?: string[]
    theme: 'dark' | 'light'
    onIndexChange?: (event: GaleriaIndexChangedEvent) => void
    onPressRightNavItemIcon?: (event: GaleriaRightNavItemPressedEvent) => void
    onPressRightNavItemSecondaryIcon?: (
      event: GaleriaRightNavItemPressedEvent
    ) => void
  }
>('Galeria')

const noop = () => {}
const galeriaModule = NativeModulesProxy.Galeria

const Galeria = Object.assign(
  function Galeria({
    children,
    urls,
    theme = 'dark',
    ids,
    mediaTypes,
    rightNavItemIconName,
    rightNavItemSecondaryIconName,
    rightNavItemSecondaryDestructive,
    onPressRightNavItemIcon,
    onPressRightNavItemSecondaryIcon,
  }: {
    children: React.ReactNode
  } & Partial<
    Pick<
      GaleriaContext,
      | 'theme'
      | 'ids'
      | 'urls'
      | 'mediaTypes'
      | 'rightNavItemIconName'
      | 'rightNavItemSecondaryIconName'
      | 'rightNavItemSecondaryDestructive'
      | 'onPressRightNavItemIcon'
      | 'onPressRightNavItemSecondaryIcon'
    >
  >) {
    return (
      <GaleriaContext.Provider
        value={{
          hideBlurOverlay: false,
          hidePageIndicators: false,
          closeIconName: undefined,
          mediaTypes,
          urls,
          theme,
          rightNavItemIconName,
          rightNavItemSecondaryIconName,
          rightNavItemSecondaryDestructive:
            rightNavItemSecondaryDestructive ?? false,
          onPressRightNavItemIcon,
          onPressRightNavItemSecondaryIcon,
          initialIndex: 0,
          open: false,
          src: '',
          setOpen: noop,
          ids,
        }}
      >
        {children}
      </GaleriaContext.Provider>
    )
  },
  {
    Image({ edgeToEdge, ...props }: GaleriaViewProps) {
      const {
        theme,
        urls,
        mediaTypes,
        rightNavItemIconName,
        rightNavItemSecondaryIconName,
        rightNavItemSecondaryDestructive,
        onPressRightNavItemIcon,
        onPressRightNavItemSecondaryIcon,
      } = useContext(GaleriaContext)

      if (__DEV__) {
        // warn the user once about unnecessary defined prop
        controlEdgeToEdgeValues({ edgeToEdge })
      }

      return (
        <NativeImage
          onIndexChange={props.onIndexChange}
          onPressRightNavItemIcon={
            props.onPressRightNavItemIcon ?? onPressRightNavItemIcon
          }
          onPressRightNavItemSecondaryIcon={
            props.onPressRightNavItemSecondaryIcon ??
            onPressRightNavItemSecondaryIcon
          }
          edgeToEdge={EDGE_TO_EDGE || (edgeToEdge ?? false)}
          theme={theme}
          urls={urls?.map((url) => {
            if (typeof url === 'string') {
              return url
            }

            return Image.resolveAssetSource(url).uri
          })}
          mediaTypes={mediaTypes}
          rightNavItemIconName={
            props.rightNavItemIconName ?? rightNavItemIconName
          }
          rightNavItemSecondaryIconName={
            props.rightNavItemSecondaryIconName ?? rightNavItemSecondaryIconName
          }
          rightNavItemSecondaryDestructive={
            props.rightNavItemSecondaryDestructive ??
            rightNavItemSecondaryDestructive ??
            false
          }
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
