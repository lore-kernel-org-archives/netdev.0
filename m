From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: au1000 eth: simplify logical expression
Date: Tue, 17 May 2016 22:03:15 -0700
Message-ID: <573BF793.3060705@gmail.com>
References: <1463529525-12504-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lunn <andrew@lunn.ch>, Ivan Vecera <ivecera@redhat.com>,
	Antonio Quartulli <a@unstable.cc>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Heinrich Schuchardt <xypron.glpk@gmx.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463529525-12504-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 17/05/2016 16:58, Heinrich Schuchardt a =E9crit :
> (a && a > 0) is equivalent to (a > 0).
>=20
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
--=20
=46lorian
