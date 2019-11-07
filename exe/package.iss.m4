#define sCompanyName        'M4_COMPANY_NAME'
#define sProductName        'M4_PRODUCT_NAME'
#define sPublisherName      'M4_PUBLISHER_NAME'
#define sPublisherUrl       'M4_PUBLISHER_URL'
#define sSupportUrl         'M4_SUPPORT_URL'
#define sBrandingFolder     'patsubst(M4_BRANDING_DIR,`/',`\\')'
#define sWinArch            'M4_WIN_ARCH'
#if {#sWinArch} == 'x86'
  #define sPlatform         'win_86'
#endif
#if {#sWinArch} == 'x64'
  #define sPlatform         'win_64'
#endif

#include "common.iss"

;[Setup]
;ShowUndisplayableLanguages = true
;UsePreviousLanguage=no
