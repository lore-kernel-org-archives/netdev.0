From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [12/*] [IPSEC] Handle local_df in IPv4
Date: Wed, 16 Mar 2005 03:28:20 +0900 (JST)
Message-ID: <20050316.032820.59615306.yoshfuji@linux-ipv6.org>
References: <20050314102614.GA9610@gondor.apana.org.au>
	<20050314212557.23f0ab09.davem@davemloft.net>
	<20050316.032537.72822422.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, kaber@trash.net, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
To: davem@davemloft.net, herbert@gondor.apana.org.au
In-Reply-To: <20050316.032537.72822422.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050316.032537.72822422.yoshfuji@linux-ipv6.org> (at Wed, 16 Mar 2005 03:25:37 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> > > that we don't have any local_df support over there.  That is, we
> > > always fragment outbound UDP/raw packets.  Did I miss something?
> > 
> > I have no idea offhand.  Perhaps Yoshifuji can figure it out?
> 
> Currently, yes.
I mean: we always fragment outbount UDP/raw packets.

--yoshfuji
