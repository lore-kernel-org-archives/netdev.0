From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 07/16] wl1251: configure hardware en-/decryption for
 monitor mode
Date: Wed, 30 Oct 2013 12:35:02 +0100
Message-ID: <20131030113502.GA8763@amd.pavel.ucw.cz>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
 <1382819655-30430-8-git-send-email-pali.rohar@gmail.com>
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
In-Reply-To: <1382819655-30430-8-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat 2013-10-26 22:34:06, Pali Roh=E1r wrote:
> From: David Gnedt <david.gnedt@davizone.at>
>=20
> Disable hardware encryption (DF_ENCRYPTION_DISABLE) and decryption
> (DF_SNIFF_MODE_ENABLE) via wl1251_acx_feature_cfg while monitor inter=
face is
> present.
>=20
> Signed-off-by: David Gnedt <david.gnedt@davizone.at>

You need to sign off the patch, otherwise looks ok.

Reviewed-by: Pavel Machek <pavel@ucw.cz>

Thanks,
									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses=
/blog.html
