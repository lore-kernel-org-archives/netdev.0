From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] netem:  de-GSO packets before enqueing
Date: Sat, 14 Jan 2012 00:44:11 +0100
Message-ID: <1326498251.5287.2.camel@edumazet-laptop>
References: <1326400930.2740.10.camel@bwh-desktop>
	 <20120112220328.GA10813@gondor.apana.org.au>
	 <20120112165720.4545c670@nehalam.linuxnetplumber.net>
	 <1326470097.3826.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120113112028.4a24d988@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120113112028.4a24d988@nehalam.linuxnetplumber.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 13 janvier 2012 =C3=A0 11:20 -0800, Stephen Hemminger a =C3=
=A9crit :

> Also, does pkt_len need to be set in cb after de-gso?

Yes, most probably :)


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
