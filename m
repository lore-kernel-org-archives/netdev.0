From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 6/9 RESENT] staging: r8188eu: Fix sparse warnings in rtw_mlme_ext.c
Date: Fri, 18 Oct 2013 16:36:26 -0500
Message-ID: <5261A9DA.8060002@lwfinger.net>
References: <1382129563-8496-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	devel@driverdev.osuosl.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:50198 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752956Ab3JRVg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 17:36:29 -0400
Received: by mail-ob0-f181.google.com with SMTP id va2so3513777obc.40
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 14:36:28 -0700 (PDT)
In-Reply-To: <1382129563-8496-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sparse displays the following:

   CHECK   drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:1874:15: warning: incorrect type 
in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:1874:15:    expected unsigned 
short *fctrl
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:1874:15:    got restricted __le16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:2221:15: warning: incorrect type 
in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:2221:15:    expected unsigned 
short *fctrl
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:2221:15:    got restricted __le16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:2583:15: warning: incorrect type 
in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:2583:15:    expected unsigned 
short *fctrl
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:2583:15:    got restricted __le16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:2750:15: warning: incorrect type 
in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:2750:15:    expected unsigned 
short *fctrl
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:2750:15:    got restricted __le16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:3002:15: warning: incorrect type 
in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:3002:15:    expected unsigned 
short *fctrl
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:3002:15:    got restricted __le16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:3197:15: warning: incorrect type 
in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:3197:15:    expected unsigned 
short *fctrl
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:3197:15:    got restricted __le16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:3311:15: warning: incorrect type 
in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:3311:15:    expected unsigned 
short *fctrl
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:3311:15:    got restricted __le16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:3563:15: warning: incorrect type 
in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:3563:15:    expected unsigned 
short *fctrl
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:3563:15:    got restricted __le16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:4522:15: warning: incorrect type 
in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:4522:15:    expected unsigned 
short *fctrl
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:4522:15:    got restricted __le16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:4750:15: warning: incorrect type 
in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:4750:15:    expected unsigned 
short *fctrl
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:4750:15:    got restricted __le16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:4906:15: warning: incorrect type 
in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:4906:15:    expected unsigned 
short *fctrl
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:4906:15:    got restricted __le16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:5040:15: warning: incorrect type 
in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:5040:15:    expected unsigned 
short *fctrl
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:5040:15:    got restricted __le16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:5184:15: warning: incorrect type 
in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:5184:15:    expected unsigned 
short *fctrl
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:5184:15:    got restricted __le16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:5322:15: warning: incorrect type 
in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:5322:15:    expected unsigned 
short *fctrl
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:5322:15:    got restricted __le16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:5654:15: warning: incorrect type 
in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:5654:15:    expected unsigned 
short *fctrl
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:5654:15:    got restricted __le16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:5769:15: warning: incorrect type 
in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:5769:15:    expected unsigned 
short *fctrl
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:5769:15:    got restricted __le16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:5894:15: warning: incorrect type 
in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:5894:15:    expected unsigned 
short *fctrl
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:5894:15:    got restricted __le16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:5996:15: warning: incorrect type 
in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:5996:15:    expected unsigned 
short *fctrl
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:5996:15:    got restricted __le16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:6066:15: warning: incorrect type 
in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:6066:15:    expected unsigned 
short [usertype] *fctrl
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:6066:15:    got restricted __le16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:6200:15: warning: incorrect type 
in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:6200:15:    expected unsigned 
short *fctrl
drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:6200:15:    got restricted __le16 
*<noident>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
  drivers/staging/rtl8188eu/core/rtw_mlme_ext.c | 41 ++++++++++++++-------------
  1 file changed, 21 insertions(+), 20 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c 
b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
index 9982dd0..7ab5ff0 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
@@ -1852,7 +1852,7 @@ void issue_p2p_GO_request(struct adapter *padapter, u8 *raddr)
  	struct pkt_attrib *pattrib;
  	unsigned char *pframe;
  	struct rtw_ieee80211_hdr	*pwlanhdr;
-	unsigned short *fctrl;
+	__le16 *fctrl;
  	struct xmit_priv *pxmitpriv = &(padapter->xmitpriv);
  	struct mlme_ext_priv	*pmlmeext = &(padapter->mlmeextpriv);
  	struct wifidirect_info	*pwdinfo = &(padapter->wdinfo);
@@ -2199,7 +2199,7 @@ static void issue_p2p_GO_response(struct adapter 
*padapter, u8 *raddr, u8 *frame
  	struct pkt_attrib			*pattrib;
  	unsigned char					*pframe;
  	struct rtw_ieee80211_hdr	*pwlanhdr;
-	unsigned short				*fctrl;
+	__le16 *fctrl;
  	struct xmit_priv			*pxmitpriv = &(padapter->xmitpriv);
  	struct mlme_ext_priv	*pmlmeext = &(padapter->mlmeextpriv);
  	struct wifidirect_info	*pwdinfo = &(padapter->wdinfo);
@@ -2561,7 +2561,7 @@ static void issue_p2p_GO_confirm(struct adapter *padapter, 
u8 *raddr, u8 result)
  	struct pkt_attrib			*pattrib;
  	unsigned char					*pframe;
  	struct rtw_ieee80211_hdr	*pwlanhdr;
-	unsigned short				*fctrl;
+	__le16 *fctrl;
  	struct xmit_priv			*pxmitpriv = &(padapter->xmitpriv);
  	struct mlme_ext_priv	*pmlmeext = &(padapter->mlmeextpriv);
  	struct wifidirect_info	*pwdinfo = &(padapter->wdinfo);
@@ -2729,7 +2729,7 @@ void issue_p2p_invitation_request(struct adapter 
*padapter, u8 *raddr)
  	struct pkt_attrib			*pattrib;
  	unsigned char					*pframe;
  	struct rtw_ieee80211_hdr	*pwlanhdr;
-	unsigned short				*fctrl;
+	__le16 *fctrl;
  	struct xmit_priv			*pxmitpriv = &(padapter->xmitpriv);
  	struct mlme_ext_priv	*pmlmeext = &(padapter->mlmeextpriv);
  	struct wifidirect_info	*pwdinfo = &(padapter->wdinfo);
@@ -2981,7 +2981,7 @@ void issue_p2p_invitation_response(struct adapter 
*padapter, u8 *raddr, u8 dialo
  	struct pkt_attrib			*pattrib;
  	unsigned char					*pframe;
  	struct rtw_ieee80211_hdr	*pwlanhdr;
-	unsigned short				*fctrl;
+	__le16 *fctrl;
  	struct xmit_priv			*pxmitpriv = &(padapter->xmitpriv);
  	struct mlme_ext_priv	*pmlmeext = &(padapter->mlmeextpriv);
  	struct wifidirect_info	*pwdinfo = &(padapter->wdinfo);
@@ -3175,7 +3175,7 @@ void issue_p2p_provision_request(struct adapter *padapter, 
u8 *pssid, u8 ussidle
  	struct pkt_attrib			*pattrib;
  	unsigned char					*pframe;
  	struct rtw_ieee80211_hdr	*pwlanhdr;
-	unsigned short				*fctrl;
+	__le16 *fctrl;
  	struct xmit_priv			*pxmitpriv = &(padapter->xmitpriv);
  	struct mlme_ext_priv	*pmlmeext = &(padapter->mlmeextpriv);
  	struct wifidirect_info	*pwdinfo = &(padapter->wdinfo);
@@ -3283,7 +3283,7 @@ void issue_probersp_p2p(struct adapter *padapter, unsigned 
char *da)
  	struct pkt_attrib			*pattrib;
  	unsigned char					*pframe;
  	struct rtw_ieee80211_hdr	*pwlanhdr;
-	unsigned short				*fctrl;
+	__le16 *fctrl;
  	unsigned char					*mac;
  	struct xmit_priv	*pxmitpriv = &(padapter->xmitpriv);
  	struct mlme_ext_priv	*pmlmeext = &(padapter->mlmeextpriv);
@@ -3534,7 +3534,7 @@ static int _issue_probereq_p2p(struct adapter *padapter, 
u8 *da, int wait_ack)
  	struct pkt_attrib		*pattrib;
  	unsigned char			*pframe;
  	struct rtw_ieee80211_hdr	*pwlanhdr;
-	unsigned short		*fctrl;
+	__le16 *fctrl;
  	unsigned char			*mac;
  	struct xmit_priv		*pxmitpriv = &(padapter->xmitpriv);
  	struct mlme_ext_priv	*pmlmeext = &(padapter->mlmeextpriv);
@@ -4484,7 +4484,7 @@ void issue_beacon(struct adapter *padapter, int timeout_ms)
  	struct pkt_attrib	*pattrib;
  	unsigned char	*pframe;
  	struct rtw_ieee80211_hdr *pwlanhdr;
-	unsigned short *fctrl;
+	__le16 *fctrl;
  	unsigned int	rate_len;
  	struct xmit_priv	*pxmitpriv = &(padapter->xmitpriv);
  #if defined(CONFIG_88EU_AP_MODE)
@@ -4713,7 +4713,7 @@ void issue_probersp(struct adapter *padapter, unsigned 
char *da, u8 is_valid_p2p
  	struct pkt_attrib			*pattrib;
  	unsigned char					*pframe;
  	struct rtw_ieee80211_hdr	*pwlanhdr;
-	unsigned short				*fctrl;
+	__le16 *fctrl;
  	unsigned char					*mac, *bssid;
  	struct xmit_priv	*pxmitpriv = &(padapter->xmitpriv);
  #if defined (CONFIG_88EU_AP_MODE)
@@ -4876,7 +4876,7 @@ static int _issue_probereq(struct adapter *padapter, 
struct ndis_802_11_ssid *ps
  	struct pkt_attrib		*pattrib;
  	unsigned char			*pframe;
  	struct rtw_ieee80211_hdr	*pwlanhdr;
-	unsigned short		*fctrl;
+	__le16 *fctrl;
  	unsigned char			*mac;
  	unsigned char			bssrate[NumRates];
  	struct xmit_priv		*pxmitpriv = &(padapter->xmitpriv);
@@ -5013,7 +5013,7 @@ void issue_auth(struct adapter *padapter, struct sta_info 
*psta, unsigned short
  	struct pkt_attrib *pattrib;
  	unsigned char *pframe;
  	struct rtw_ieee80211_hdr *pwlanhdr;
-	unsigned short *fctrl;
+	__le16 *fctrl;
  	unsigned int val32;
  	u16 val16;
  #ifdef CONFIG_88EU_AP_MODE
@@ -5153,7 +5153,7 @@ void issue_asocrsp(struct adapter *padapter, unsigned 
short status, struct sta_i
  	struct pkt_attrib *pattrib;
  	unsigned char	*pbuf, *pframe;
  	unsigned short val;
-	unsigned short *fctrl;
+	__le16 *fctrl;
  	struct xmit_priv *pxmitpriv = &(padapter->xmitpriv);
  	struct mlme_priv *pmlmepriv = &(padapter->mlmepriv);
  	struct mlme_ext_priv *pmlmeext = &padapter->mlmeextpriv;
@@ -5290,7 +5290,7 @@ void issue_assocreq(struct adapter *padapter)
  	struct pkt_attrib	*pattrib;
  	unsigned char		*pframe, *p;
  	struct rtw_ieee80211_hdr	*pwlanhdr;
-	unsigned short	*fctrl;
+	__le16 *fctrl;
  	__le16		le_tmp;
  	unsigned int	i, j, ie_len, index = 0;
  	unsigned char	rf_type, bssrate[NumRates], sta_bssrate[NumRates];
@@ -5625,7 +5625,7 @@ static int _issue_nulldata(struct adapter *padapter, 
unsigned char *da, unsigned
  	struct pkt_attrib			*pattrib;
  	unsigned char					*pframe;
  	struct rtw_ieee80211_hdr	*pwlanhdr;
-	unsigned short				*fctrl;
+	__le16 *fctrl;
  	struct xmit_priv	*pxmitpriv;
  	struct mlme_ext_priv	*pmlmeext;
  	struct mlme_ext_info	*pmlmeinfo;
@@ -5740,7 +5740,8 @@ static int _issue_qos_nulldata(struct adapter *padapter, 
unsigned char *da, u16
  	struct pkt_attrib			*pattrib;
  	unsigned char					*pframe;
  	struct rtw_ieee80211_hdr	*pwlanhdr;
-	unsigned short				*fctrl, *qc;
+	__le16 *fctrl;
+	unsigned short *qc;
  	struct xmit_priv			*pxmitpriv = &(padapter->xmitpriv);
  	struct mlme_ext_priv	*pmlmeext = &(padapter->mlmeextpriv);
  	struct mlme_ext_info	*pmlmeinfo = &(pmlmeext->mlmext_info);
@@ -5860,7 +5861,7 @@ static int _issue_deauth(struct adapter *padapter, 
unsigned char *da, unsigned s
  	struct pkt_attrib			*pattrib;
  	unsigned char					*pframe;
  	struct rtw_ieee80211_hdr	*pwlanhdr;
-	unsigned short				*fctrl;
+	__le16 *fctrl;
  	struct xmit_priv			*pxmitpriv = &(padapter->xmitpriv);
  	struct mlme_ext_priv	*pmlmeext = &(padapter->mlmeextpriv);
  	struct mlme_ext_info	*pmlmeinfo = &(pmlmeext->mlmext_info);
@@ -5972,7 +5973,7 @@ void issue_action_spct_ch_switch (struct adapter 
*padapter, u8 *ra, u8 new_ch, u
  	struct pkt_attrib			*pattrib;
  	unsigned char				*pframe;
  	struct rtw_ieee80211_hdr	*pwlanhdr;
-	unsigned short			*fctrl;
+	__le16 *fctrl;
  	struct xmit_priv			*pxmitpriv = &(padapter->xmitpriv);
  	struct mlme_ext_priv	*pmlmeext = &(padapter->mlmeextpriv);
  @@ -6040,7 +6041,7 @@ void issue_action_BA(struct adapter *padapter, unsigned 
char *raddr, unsigned ch
  	struct pkt_attrib *pattrib;
  	u8 *pframe;
  	struct rtw_ieee80211_hdr *pwlanhdr;
-	u16 *fctrl;
+	__le16 *fctrl;
  	struct xmit_priv *pxmitpriv = &(padapter->xmitpriv);
  	struct mlme_ext_priv *pmlmeext = &(padapter->mlmeextpriv);
  	struct mlme_ext_info *pmlmeinfo = &(pmlmeext->mlmext_info);
@@ -6162,7 +6163,7 @@ static void issue_action_BSSCoexistPacket(struct adapter 
*padapter)
  	struct pkt_attrib			*pattrib;
  	unsigned char				*pframe;
  	struct rtw_ieee80211_hdr	*pwlanhdr;
-	unsigned short			*fctrl;
+	__le16 *fctrl;
  	struct	wlan_network	*pnetwork = NULL;
  	struct xmit_priv			*pxmitpriv = &(padapter->xmitpriv);
  	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
-- 
1.8.4
