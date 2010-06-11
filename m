From: Dmytro Milinevskyy <milinevskyy@gmail.com>
Subject: Re: [ath5k-devel] [PATCH] [ath5k][leds] Ability to disable leds
	support. If leds support enabled do not force mac802.11 leds layer selection.
Date: Fri, 11 Jun 2010 22:52:00 +0300
Message-ID: <AANLkTilECEFWIxXTfykAagSaZUv20Btrz-Fmq3IA8Dap@mail.gmail.com>
References: <4c0f4326.0a41df0a.7bde.ffffeef2@mx.google.com>
	<AANLkTilrYYHjcMEhhrP7zjcLoo-TNczozxJSNRkDvSZy@mail.gmail.com>
	<AANLkTimXqdkQxv_Y1JaleTTWNsDIQHQaPn8HR7efOupb@mail.gmail.com>
	<AANLkTimUW58T19GOkRk3oCC9huLDQLgLj4W3RjiQ9n53@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Kalle Valo <kalle.valo@iki.fi>,
	GeunSik Lim <geunsik.lim@samsung.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Jiri Slaby <jirislaby@gmail.com>, netdev@vger.kernel.org,
	ath5k-devel@lists.ath5k.org, linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Keng-Yu Lin <keng-yu.lin@canonical.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Shahar Or <shahar@shahar-or.co.il>,
	linux-kernel@vger.kernel.org, Luca Verdesca <magooz@salug.it>
To: Bob Copeland <me@bobcopeland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimUW58T19GOkRk3oCC9huLDQLgLj4W3RjiQ9n53@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I didn't know. Thank you for noting that.
However I think it's better to give a chance to disable 802.11 leds.

-- Dima

On Fri, Jun 11, 2010 at 8:07 PM, Bob Copeland <me@bobcopeland.com> wrote:
> On Wed, Jun 9, 2010 at 10:43 AM, Dmytro Milinevskyy
> <milinevskyy@gmail.com> wrote:
>> Hi, Bob.
>>
>> For instance I don't use 802.11 leds layer and trigger leds from
>> userspace according to my purposes.
>
> FWIW you can disable mac80211 triggers from userspace as well.
> But, I guess hooking up null triggers will work too.
>
> --
> Bob Copeland %% www.bobcopeland.com
>
