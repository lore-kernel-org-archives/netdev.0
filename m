From: David Miller <davem@davemloft.net>
Subject: Re: [V9fs-developer] [PATCH] net: trans_rdma: remove unused
 function
Date: Thu, 25 Jul 2013 01:35:50 -0700 (PDT)
Message-ID: <20130725.013550.930278380548483073.davem@davemloft.net>
References: <20130725061411.GA8579@nautica>
	<20130725064802.GA12569@nautica>
	<20130725082741.GB4295@jack.whiskey>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dominique.martinet@cea.fr, pebolle@tiscali.nl, lucho@ionkov.net,
	ericvh@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
	rminnich@sandia.gov
To: andi@etezian.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130725082741.GB4295@jack.whiskey>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Shyti <andi@etezian.org>
Date: Thu, 25 Jul 2013 10:27:41 +0200

> I would prefer to NACK my patch, it messes up things more than
> fixes.

Your patch it already applied to my tree, so you must send me
something which fixes things.

> If we really want to get rid of this function we should
> completely revert this patch:
> 
> 80b45261a0b263536b043c5ccfc4ba4fc27c2acc

Such as this.
