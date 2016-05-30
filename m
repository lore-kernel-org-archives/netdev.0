From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH v2 08/10] nl80211: Fix spelling
Date: Mon, 30 May 2016 15:31:24 +1000
Message-ID: <CAGRGNgXTJvHrZmgTh6bT02VQQbS0qb2Rh5tBBjcr7zse5kq9+A@mail.gmail.com>
References: <cover.1464576022.git.kirtika.ruchandani@gmail.com> <44f8047ab65f9c6aa190eb870590102cd2297ab1.1464576022.git.kirtika.ruchandani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Tina Ruchandani <ruchandani.tina@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:35977 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137AbcE3Fbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 01:31:44 -0400
In-Reply-To: <44f8047ab65f9c6aa190eb870590102cd2297ab1.1464576022.git.kirtika.ruchandani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

On Mon, May 30, 2016 at 12:54 PM, Kirtika Ruchandani
<kirtika.ruchandani@gmail.com> wrote:
> Fix 'implementation' spelling, reported by checkpatch.pl
>
> Signed-off-by: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>

Looks right to me.

Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

Thanks,

Julian Calaby


> ---
>  net/wireless/nl80211.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
> index 6f8e2a7..c6d870e 100644
> --- a/net/wireless/nl80211.c
> +++ b/net/wireless/nl80211.c
> @@ -6492,7 +6492,7 @@ nl80211_parse_sched_scan(struct wiphy *wiphy, struct wireless_dev *wdev,
>                                        nla_data(ssid), nla_len(ssid));
>                                 request->match_sets[i].ssid.ssid_len =
>                                         nla_len(ssid);
> -                               /* special attribute - old implemenation w/a */
> +                               /* special attribute - old implementation w/a */
>                                 request->match_sets[i].rssi_thold =
>                                         default_match_rssi;
>                                 rssi = tb[NL80211_SCHED_SCAN_MATCH_ATTR_RSSI];
> --
> 2.8.0.rc3.226.g39d4020
>



-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
