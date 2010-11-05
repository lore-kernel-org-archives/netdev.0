From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 46/49] net/netfilter: Use vzalloc
Date: Fri, 05 Nov 2010 08:16:11 +0100
Message-ID: <1288941371.3234.31.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1011031108260.11625@router.home>
	 <7d6da34b7e84955795717b0241000a0701cd5b34.1288925425.git.joe@perches.com>
	 <1288938640.3234.12.camel@edumazet-laptop>
	 <1288940146.18440.55.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Juhl <jj@chaosbits.net>, Jiri Kosina <trivial@kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1288940146.18440.55.camel@Joe-Laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 04 novembre 2010 =C3=A0 23:55 -0700, Joe Perches a =C3=A9crit =
:
> On Fri, 2010-11-05 at 07:30 +0100, Eric Dumazet wrote:
> > I had _one_ patch, waiting that David actually had vzalloc() in its=
 tree
> > before sending it.
>=20
> Fine by me, use yours.

I dont care at all, only to say that David tree was not ready yet.


>=20
> > Given Jesper Juhl was doing this work, could you please take anothe=
r
> > one, please ?
> > For example, explaining him how to use other tools than "bash+egrep
> > +manual inspection" as he mentioned in a previous mail.
>=20
> Jesper Juhl was both pointed at the cocci docs and
> given a cocci script.  He said he'd investigate it
> when he could.  I trust he will get to it.
>=20

Yes, yet you posted patches, knowing he was working on the _same_
subject.

I remember other occurrences of such behavior.

I find this behavior very unfriendly, time consuming, and not useful.

We try to work together, to increase our common knowledge, not to throw
a bunch of patches "just because I know better than you"



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
