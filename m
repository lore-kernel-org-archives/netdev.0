From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Thu, 19 May 2005 07:46:54 +1000
Message-ID: <E1DYWNS-0004ju-00@gondolin.me.apana.org.au>
References: <20050518174454.GD15391@postel.suug.ch>
Cc: rick.jones2@hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch (Thomas Graf)
In-Reply-To: <20050518174454.GD15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf <tgraf@suug.ch> wrote:
> 
> Wild thought: We could introduce a new ip option stating that the id
> generator uses a serial approach which would give us the possibility
> to measure the absolute distance and resolve this issue in a perfect
> matter for everyone supporting this extension. ;->

Well Linux does that anyway (apart from Suse) so all we need to do
is to tell everyone doing NFS over gigabit to use Linux :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
