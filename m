From: jamal <hadi@cyberus.ca>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: 02 Apr 2005 15:47:36 -0500
Message-ID: <1112474855.1096.274.camel@jzny.localdomain>
References: <E1DHdsP-0003Lr-00@gondolin.me.apana.org.au>
	 <424E641A.1020609@cosmosbay.com> <16974.41648.568927.54429@robur.slu.se>
	 <424EA7C2.6060308@cosmosbay.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <424EA7C2.6060308@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-04-02 at 09:10, Eric Dumazet wrote:
> Robert Olsson a =E9crit :
> > Eric Dumazet writes:
>=20
> >  Yes thats a pretty much load. Very short flows some reason?
>=20
> Well... yes. This is a real server, not a DOS simulation.
> 1 million TCP flows, and about 3 million peers using UDP frames.

SMP? How many processors?

cheers,
jamal
