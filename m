From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the rdma tree with the net-next
 tree
Date: Thu, 17 Mar 2016 09:35:31 +1100
Message-ID: <20160317093531.4894f078@canb.auug.org.au>
References: <20160316115809.61b4478e@canb.auug.org.au>
	<CA+55aFzhYJxCOXER-mhOfJ6=V13Rb5F0LB_3A9n7S_dLkb8f0g@mail.gmail.com>
	<20160317075246.39a08e61@canb.auug.org.au>
	<20160316211503.GA16382@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Doug Ledford <dledford@redhat.com>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	linux-next <linux-next@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Amir Vadai <amir@vadai.me>, Maor Gottlieb <maorg@mellanox.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:59556 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750955AbcCPWfe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 18:35:34 -0400
In-Reply-To: <20160316211503.GA16382@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Wed, 16 Mar 2016 22:15:03 +0100 Andrew Lunn <andrew@lunn.ch> wrote:
>
> > How about "This is now fixed as far as linux-next is concerned, but any
> > non trivial conflicts should be mentioned to your upstream maintainer
> > when your tree is submitted for merging.  You may want also want to  
> 
> Only the second want is required.
> 
> > consider cooperate with the maintainer of the conflicting tree to  
> 
> cooperating

Thanks.  Breakfast is not the best time to compose prose :-)

-- 
Cheers,
Stephen Rothwell
