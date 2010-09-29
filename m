From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: null dereference in ipip6_get_stats in linux-next
Date: Wed, 29 Sep 2010 18:48:35 +0200
Message-ID: <1285778915.2813.163.camel@edumazet-laptop>
References: <20100929162625.GB17087@fieldses.org>
	 <AANLkTin2E2ACB5yiAUA7MbYqzYyMKAi+syFOCzXWqVrY@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <AANLkTin2E2ACB5yiAUA7MbYqzYyMKAi+syFOCzXWqVrY@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 29 septembre 2010 =C3=A0 09:39 -0700, Jesse Gross a =C3=A9c=
rit :
> On Wed, Sep 29, 2010 at 9:26 AM, J. Bruce Fields <bfields@fieldses.or=
g> wrote:
> > Last night's linux-next fails to boot for me; apologies if this is =
already
> > known.
>=20
> Eric sent out a patch for this:
> http://patchwork.ozlabs.org/patch/65961/

Also same kind of problem for ipip :

 http://patchwork.ozlabs.org/patch/65951/

Sorry guys :(
