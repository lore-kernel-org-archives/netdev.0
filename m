From: Lee Jones <lee.jones@linaro.org>
Subject: Re: [PATCH 4/4 v3] net/smsc911x: Provide common clock functionality
Date: Mon, 7 Jan 2013 14:16:48 +0000
Message-ID: <20130107141648.GR21994@gmail.com>
References: <1355937587-31730-4-git-send-email-lee.jones@linaro.org>
 <CACRpkda79O_b3Z8g7Sy7vMtW9neZU4x-Z=iEQgjqu4X5tFKyhw@mail.gmail.com>
 <20121220192441.GC14363@n2100.arm.linux.org.uk>
 <20121220203514.GN2691@gmail.com>
 <20121220205113.GD14363@n2100.arm.linux.org.uk>
 <20121221091306.GO2691@gmail.com>
 <20121221092421.GG14363@n2100.arm.linux.org.uk>
 <20121221114105.GP2691@gmail.com>
 <20130103111450.GC14714@gmail.com>
 <CACRpkda-4C+ezaZFSkxsNbmHnBN8RCoCeGePaOF-DzV0XnkzQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	Robert Marklund <robert.marklund@stericsson.com>,
	linus.walleij@stericsson.com, arnd@arndb.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACRpkda-4C+ezaZFSkxsNbmHnBN8RCoCeGePaOF-DzV0XnkzQw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 03 Jan 2013, Linus Walleij wrote:

> On Thu, Jan 3, 2013 at 12:14 PM, Lee Jones <lee.jones@linaro.org> wro=
te:
>=20
> > Some platforms provide clocks which require enabling before the
> > SMSC911x chip will power on. This patch uses the new common clk
> > framework to do just that. If no clock is provided, it will just
> > be ignored and the driver will continue to assume that no clock
> > is required for the chip to run successfully.
> >
> > Cc: Steve Glendinning <steve.glendinning@shawell.net>
> > Cc: netdev@vger.kernel.org
> > Signed-off-by: Lee Jones <lee.jones@linaro.org>
>=20
> Looks all right to me now:
> Reviewed-by: Linus Walleij <linus.walleij@linaro.org>

Great, thanks Linus.

Who will take this patch now?

--=20
Lee Jones
Linaro ST-Ericsson Landing Team Lead
Linaro.org =E2=94=82 Open source software for ARM SoCs
=46ollow Linaro: Facebook | Twitter | Blog
