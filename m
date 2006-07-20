From: David Miller <davem@davemloft.net>
Subject: Re: Oops in IFB
Date: Thu, 20 Jul 2006 16:16:15 -0700 (PDT)
Message-ID: <20060720.161615.105821005.davem@davemloft.net>
References: <44BF8628.9080204@6wind.com>
	<1153402801.5098.66.camel@jzny2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:8389
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030405AbWGTXQM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jul 2006 19:16:12 -0400
To: hadi@cyberus.ca
In-Reply-To: <1153402801.5098.66.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Thu, 20 Jul 2006 09:40:00 -0400

> On Thu, 2006-20-07 at 15:33 +0200, Nicolas DICHTEL wrote:
> 
> 
> > [IFB] After ifb_init_one() failed, i is increased. Decrease
> > it before entering in the loop for freeing the other ifb devices.
> > 
> > Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> 
> Thanks Nicolas.
> 
> Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

Applied, thanks a lot.
