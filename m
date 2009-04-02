From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 2 Apr 2009 16:54:11 +0800
Message-ID: <20090402085411.GA29967@gondor.apana.org.au>
References: <20090402030935.GA27836@gondor.apana.org.au> <49D45F59.9030100@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anthony Liguori <anthony@codemonkey.ws>, andi@firstfloor.org,
	ghaskins@novell.com, linux-kernel@vger.kernel.org, agraf@suse.de,
	pmullaney@novell.com, pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49D45F59.9030100@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 02, 2009 at 09:46:49AM +0300, Avi Kivity wrote:
>
> I don't understand this.  If we had good interfaces, all that userspace  
> would do is translate guest physical addresses to host physical  
> addresses, and translate the guest->host protocol to host API calls.  I  
> don't see anything there that benefits from being in the kernel.
>
> Can you elaborate?

I think Greg has expressed it clearly enough.

At the end of the day, the numbers speak for themselves.  So if
and when there's a user-space version that achieves the same or
better results, then I will change my mind :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
