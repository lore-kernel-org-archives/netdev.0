From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: add CONFIG_NET_DSA_LEGACY
Date: Thu, 21 Jul 2016 16:52:42 +0200
Message-ID: <20160721145242.GP11309@lunn.ch>
References: <20160720222641.30899-1-vivien.didelot@savoirfairelinux.com>
 <20160721003545.GB22834@lunn.ch>
 <2af1c57a-b1f1-7d6e-ef72-4f4c34830045@gmail.com>
 <87zipbm4kf.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87zipbm4kf.fsf@ketchup.mtl.sfl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 21, 2016 at 10:46:56AM -0400, Vivien Didelot wrote:
> Florian Fainelli <f.fainelli@gmail.com> writes:
>=20
> > Le 20/07/2016 =E0 17:35, Andrew Lunn a =E9crit :
> >> On Wed, Jul 20, 2016 at 06:26:41PM -0400, Vivien Didelot wrote:
> >>> This patch simply moves the legacy DSA code from dsa.c to legacy.=
c,
> >>> except the few shared symbols which remain in dsa.c.
> >>=20
> >> I think it is a bit early for this. Lets convert all in kernel use=
rs
> >> to the new binding first.
> >
> > Fine with me, let's try to get the in-tree DTS files converted to t=
he
> > new binding by v4.9 so we can then introduce this Kconfig symbol an=
d
> > start producing warnings if the old binding is encountered, how doe=
s
> > that sound?
>=20
> If you guys prefer going that way, that's fine with me too ;-)

Yes, i would prefer that.

     Andrew
