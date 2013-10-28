From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 15/16] wl1251: Add sysfs file tx_mgmt_frm_rate for
 setting rate
Date: Mon, 28 Oct 2013 14:45:54 +0100
Message-ID: <1382967954.17956.9.camel@jlt4.sipsolutions.net>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
	 <1382819655-30430-16-git-send-email-pali.rohar@gmail.com>
	 (sfid-20131026_224039_612331_A01681C8)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com
To: Pali =?ISO-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382819655-30430-16-git-send-email-pali.rohar@gmail.com> (sfid-20131026_224039_612331_A01681C8)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-10-26 at 22:34 +0200, Pali Roh=C3=A1r wrote:
> This patch was extracted from Maemo 2.6.28 kernel

That's not a description or justification for the patch ....

but again, it seems like a bad idea to use sysfs.

johannes
