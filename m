From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] inet: Add skb_copy_datagram_iter
Date: Thu, 06 Nov 2014 12:25:00 -0500 (EST)
Message-ID: <20141106.122500.4643339498907490.davem@davemloft.net>
References: <E1XlZWY-0003HZ-Ef@gondolin.me.apana.org.au>
	<20141105.152410.1775725940252546246.davem@davemloft.net>
	<20141106082338.GA29800@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141106082338.GA29800@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 6 Nov 2014 16:23:38 +0800

> On Wed, Nov 05, 2014 at 03:24:10PM -0500, David Miller wrote:
>> 
>> Herbert, please provide a cover letter for this series, and the most recent
>> version of patch #2 gets various rejects when I try to apply it to net-next.
> 
> Sure, I'll regenerate them.  However, while doing so I noticed that
> a number of my patches on tun/macvtap that you have previously set
> as accepted are missing from net-next.  Could this be why you got
> the rejects?

Those were bug fixes so went into plain 'net', they will show up next
time I do a merge and I will deal with the conflicts, if any.
