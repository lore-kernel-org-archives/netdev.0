From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.11 oops in skb_drop_fraglist
Date: Tue, 22 Mar 2005 12:19:51 +1100
Message-ID: <E1DDY3j-00047A-00@gondolin.me.apana.org.au>
References: <20050321162444.31c6c68d.akpm@osdl.org>
Cc: cel@citi.umich.edu, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
To: akpm@osdl.org (Andrew Morton)
In-Reply-To: <20050321162444.31c6c68d.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
> Chuck Lever <cel@citi.umich.edu> wrote:
>>
>> testing NFS client workloads on a dual Pentium-III system running 2.6.11 
>> with some NFS patches.  i hit this oops while doing simple-minded ftps 
>> and tars.
>> 
>> the system locks up once or twice a day under this workload.  this is 
>> the first time i had the console and captured the oops output.
> 
> Chuck, I didn't see any followup to this.  Is it still happening in current
> kernels?

In the past the same Oops have been caused by memory problems...
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
