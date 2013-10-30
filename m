From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 12/16] wl1251: disable retry and ACK policy for
 injected packets
Date: Wed, 30 Oct 2013 12:52:51 +0100
Message-ID: <20131030115251.GF8763@amd.pavel.ucw.cz>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
 <1382819655-30430-13-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, sre@ring0.de, joni.lapilainen@gmail.com,
	David Gnedt <david.gnedt@davizone.at>
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1382819655-30430-13-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat 2013-10-26 22:34:11, Pali Roh=E1r wrote:
> From: David Gnedt <david.gnedt@davizone.at>
>=20
> Set the retry limit to 0 and disable the ACK policy for injected pack=
ets.
>=20
> Signed-off-by: David Gnedt <david.gnedt@davizone.at>

Missing sign-off, otherwise ok:

Reviewed-by: Pavel Machek <pavel@ucw.cz>
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses=
/blog.html
