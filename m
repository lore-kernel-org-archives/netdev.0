From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: linux-next: manual merge of the devicetree tree with the net tree
Date: Tue, 18 May 2010 23:30:03 -0600
Message-ID: <AANLkTikYNsOIXZFpqdTgFsTNkxc6xDuVOmnZJCrAw6jM@mail.gmail.com>
References: <20100519152301.ad6cd9e9.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Grant Likely <grant.likely@secretlab.ca>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Anton Vorontsov <avorontsov@mvista.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100519152301.ad6cd9e9.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, May 18, 2010, Stephen Rothwell <sfr@canb.auug.org.au> wrote=
:
> Hi Grant,
>
> Today's linux-next merge of the devicetree tree got a conflict in
> drivers/net/gianfar.c between commit
> b14ed884df5968b0977114ebd5a22f58d0d15315 ("gianfar: Remove legacy PM
> callbacks") from the net tree and commit
> 030d1870b731924034caf0c874981e2ed4f1becc ("drivers/net/of: don't use
> deprecated field in of_platform_driver") from the devicetree tree.
>
> Just context changes. =A0I fixed it up (see below) and can carry the =
fix as
> necessary.

Looks right to me.  I'll probably wait until this and the other
conflicting trees are merged by Linus before I send him my pull
request so I can include the fixups.

Thanks,
g.


--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
