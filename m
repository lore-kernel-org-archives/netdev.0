From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [GIT PULL] vhost-net fix for 2.6.34-rc4
Date: Thu, 15 Apr 2010 07:05:57 +0300
Message-ID: <20100415040557.GA12108@redhat.com>
References: <20100414141733.GA5370@redhat.com> <20100414.155715.210946931.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hch@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50412 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750891Ab0DOEJq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Apr 2010 00:09:46 -0400
Content-Disposition: inline
In-Reply-To: <20100414.155715.210946931.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 14, 2010 at 03:57:15PM -0700, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Wed, 14 Apr 2010 17:17:33 +0300
> 
> > Christoph Hellwig (1):
> >       vhost: fix sparse warnings
> 
> Do the sparse warnings show actual real bugs, or are we just
> adding annotations to make the tool happy?
> 
> Unless the bugs being fixed are earth shattering, this belongs
> in net-next-2.6 not net-2.6

No, these are just annotations to make the tool happy.
Pls queue for net-next-2.6. Thanks!

-- 
MST
