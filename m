From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] phy: export phy_mii_ioctl
Date: Thu, 20 Sep 2007 02:36:17 -0400
Message-ID: <46F214E1.1060904@pobox.com>
References: <20070810095153.GC13994@moe.telargo.com> <20070902074143.GB2642@nd47.coderock.org> <fa686aa40709030857j6c36c87ek60215f812864ee0f@mail.gmail.com> <20070915121444.GA19857@nd47.coderock.org> <20070917095334.GA4546@powerlinux.fr> <20070917202140.GB2642@nd47.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely@secretlab.ca>, netdev@vger.kernel.org,
	linuxppc-embedded@ozlabs.org, sven@powerlinux.fr
To: Domen Puncer <domen@coderock.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46389 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751944AbXITGgU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 02:36:20 -0400
In-Reply-To: <20070917202140.GB2642@nd47.coderock.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Domen Puncer wrote:
> Export phy_mii_ioctl, so network drivers can use it when built
> as modules too.
> 
> Signed-off-by: Domen Puncer <domen@coderock.org>

applied


