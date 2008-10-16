From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: kernel oops when system under network stress
Date: Thu, 16 Oct 2008 14:41:42 +0800
Message-ID: <20081016064142.GA5064@gondor.apana.org.au>
References: <20081016030416.GA5551@samad.com.au> <20081015.215536.242281148.davem@davemloft.net> <20081016050810.GA8240@samad.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: Alex Samad <alex@samad.com.au>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081016050810.GA8240@samad.com.au>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 16, 2008 at 04:08:10PM +1100, Alex Samad wrote:
>
> The thing to note was (for example), when I was doing a nfs transfer, it
> would not be nfs that would crash, it would be other network based
> application that would cause the problem, for ex sshd, apache etc

So are you able to reproduce this at will?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
