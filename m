From: Kalle Valo <kvalo@adurom.com>
Subject: Re: [PATCH 01/16] mac80211: fix TX device statistics for monitor interfaces
Date: Mon, 28 Oct 2013 07:53:45 +0200
Message-ID: <87iowiszyu.fsf@purkki.adurom.net>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
	<1382819655-30430-2-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com, David Gnedt <david.gnedt@davizone.at>
To: Pali =?utf-8?Q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382819655-30430-2-git-send-email-pali.rohar@gmail.com> ("Pali
	=?utf-8?Q?Roh=C3=A1r=22's?= message of "Sat, 26 Oct 2013 22:34:00 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pali Roh=C3=A1r <pali.rohar@gmail.com> writes:

> From: David Gnedt <david.gnedt@davizone.at>
>
> Count TX packets and bytes also for monitor interfaces.
>
> Signed-of-by: David Gnedt <david.gnedt@davizone.at>

You should send mac80211 patches separately, not inside a wl1251 patchs=
et.

--=20
Kalle Valo
