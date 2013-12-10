From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v2 10/16] wl1251: enable tx path in monitor mode if
 necessary for packet injection
Date: Tue, 10 Dec 2013 10:44:01 +0100
Message-ID: <20131210094401.GK22756@amd.pavel.ucw.cz>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
 <1386494714-21070-1-git-send-email-pali.rohar@gmail.com>
 <1386494714-21070-11-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, sre@ring0.de, joni.lapilainen@gmail.com,
	Johannes Berg <johannes@sipsolutions.net>,
	Felipe Contreras <felipe.contreras@gmail.com>,
	David Gnedt <david.gnedt@davizone.at>
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1386494714-21070-11-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun 2013-12-08 10:25:08, Pali Roh=E1r wrote:
> From: David Gnedt <david.gnedt@davizone.at>
>=20
> If necessary enable the tx path in monitor mode for packet injection =
using
> the JOIN command with BSS_TYPE_STA_BSS and zero BSSID.
>=20
> Signed-off-by: David Gnedt <david.gnedt@davizone.at>
> Signed-off-by: Pali Roh=E1r <pali.rohar@gmail.com>

Reviewed-by: Pavel Machek <pavel@ucw.cz>

Thanks,
								Pavel


--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses=
/blog.html
