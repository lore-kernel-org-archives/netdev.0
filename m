From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2_poll panicking kernel
Date: Tue, 17 Jun 2008 15:47:22 -0700
Message-ID: <1213742842.5199.8.camel@dell>
References: <20080616140454.GD5350@solarflare.com>
 <1551EAE59135BE47B544934E30FC4FC002AABD77@nt-irva-0751.brcm.ad.broadcom.com>
 <20080616191354.GA11760@orion.carnet.hr>
 <20080616213821.GA8844@orion.carnet.hr>
 <20080616214829.GA9334@orion.carnet.hr>
 <1213659908.18055.26.camel@dell>
 <20080617223708.GA30292@orion.carnet.hr>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>, mirrors@debian.org
To: "Josip Rodin" <joy@entuzijast.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4426 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758299AbYFQWqA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 18:46:00 -0400
In-Reply-To: <20080617223708.GA30292@orion.carnet.hr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-06-18 at 00:37 +0200, Josip Rodin wrote:
> After applying this patch, two rsync runs went through without any problem,
> yay.
> 
> Yet, there were no alerts from the new printk in the patch...?

Please keep monitoring the printks during future rsyncs with those HTB
rules.  May be we're just lucky and not hitting the problem this time.

