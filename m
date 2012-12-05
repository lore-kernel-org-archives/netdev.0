From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next v2] bridge: export multicast database via
 netlink
Date: Wed, 05 Dec 2012 10:07:30 +0800
Message-ID: <1354673250.28951.2.camel@cr0>
References: <1354539824-7898-1-git-send-email-amwang@redhat.com>
	 <20121204.132505.1229048595483168009.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	herbert@gondor.hengli.com.au, shemminger@vyatta.com, tgraf@suug.ch,
	brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14616 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751978Ab2LECIK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 21:08:10 -0500
In-Reply-To: <20121204.132505.1229048595483168009.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-04 at 13:25 -0500, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Mon,  3 Dec 2012 21:03:43 +0800
> 
> > TODO: remove debugging printk's
> 
> Can you please take care of this so we can consider this patch
> seriously for inclusion?
> 

Sure. I planned to send V3 when I wrote this TODO. ;) And it seems
Thomas and Stephen are ok with it now, I will remove these printk's.

Thanks.
