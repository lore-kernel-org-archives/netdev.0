From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] new network drivers for net-next
Date: Thu, 18 Sep 2008 16:48:48 -0700 (PDT)
Message-ID: <20080918.164848.21252659.davem@davemloft.net>
References: <20080918160005.GA24281@havoc.gtf.org>
	<20080918.164255.120405140.davem@davemloft.net>
	<48D2E7C9.3090509@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59150
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754944AbYIRXtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 19:49:01 -0400
In-Reply-To: <48D2E7C9.3090509@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Thu, 18 Sep 2008 19:44:09 -0400

> David Miller wrote:
> > So, new-drivers destined for net-2.6 right?
> > Just making sure :-)
> 
> I based it on top of net-next for 2.6.28, but can easily retarget it for net-2.6...

Since I really want to concentrate on killing as many regression list
network driver entries as possible, I'd much rather:

1) You concentrate on building that net-2.6 bug fix tree for me

2) I pull these new drivers into net-next-2.6 for now and we can
   think about putting these into net-2.6 for a subsequent push
   to Linus, rather than the current one.

Sound good to you?
