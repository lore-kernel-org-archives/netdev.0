From: jamal <hadi@cyberus.ca>
Subject: Re: take 2-2  WAS(Re: PATCH: IPSEC xfrm events
Date: 04 Apr 2005 09:16:55 -0400
Message-ID: <1112620614.1088.489.camel@jzny.localdomain>
References: <1112403845.1088.14.camel@jzny.localdomain>
	 <20050402012813.GA24575@gondor.apana.org.au>
	 <1112406164.1088.54.camel@jzny.localdomain>
	 <20050402014619.GB24861@gondor.apana.org.au>
	 <1112469601.1088.173.camel@jzny.localdomain>
	 <1112538718.1096.394.camel@jzny.localdomain>
	 <20050404005805.GA16543@gondor.apana.org.au>
	 <1112614706.1096.439.camel@jzny.localdomain>
	 <20050404121641.GA12103@gondor.apana.org.au>
	 <1112619096.1088.473.camel@jzny.localdomain>
	 <20050404130224.GA12546@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050404130224.GA12546@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-04-04 at 09:02, Herbert Xu wrote:

> > -static struct list_head xfrm_km_list = LIST_HEAD_INIT(xfrm_km_list);
> > -static DEFINE_RWLOCK(xfrm_km_lock);
> 
> All I wanted was to leave these lines as is so that they didn't
> appear in the patch at all (except as conext) :)
>
> When reviewing patches the most annoying thing is to see things
> moved around or rearranged because that distracts the reviewer
> from the substantiative changes.

Ok, fair enough. It annoys me too when i review patches ;->
So i will fix this before final.

>  
> > ;-> Yes, indeed. I think its time for you to throw in the towel ;->
> 
> Alright I give in :)

Goody - now we can have Masahide run his full test.

cheers,
jamal
