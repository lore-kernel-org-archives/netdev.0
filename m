From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: almost identical frag hashing funcs
 combined
Date: Wed, 01 Oct 2008 02:54:26 -0700 (PDT)
Message-ID: <20081001.025426.33354887.davem@davemloft.net>
References: <Pine.LNX.4.64.0810010146001.27688@wrl-59.cs.helsinki.fi>
	<20081001011838.GB970@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org
To: acme@redhat.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081001011838.GB970@ghostprotocols.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 30 Sep 2008 22:18:38 -0300

> Em Wed, Oct 01, 2008 at 01:57:47AM +0300, Ilpo J=E4rvinen escreveu:
> > Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> Good stuff, I wonder if you can spot possible candidades by sorting b=
y
> function size... Or perhaps by function signature... perhaps a new dw=
arf
> that looks just at the parameter types, ordering by type name, and
> reducing typedefs :-)

So many cool tool ideas, so little time :-)

> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Patch applied, thanks everyone.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
