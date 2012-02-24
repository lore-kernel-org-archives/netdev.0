From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 07/11] xscale/ixp2000/ixpdev: print MAC via printk format
 specifier
Date: Fri, 24 Feb 2012 15:00:25 +0100
Message-ID: <20120224140025.GP29303@wantstofly.org>
References: <1330091162-8141-1-git-send-email-danny.kukawka@bisect.de>
 <1330091162-8141-8-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:63641 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844Ab2BXOA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2012 09:00:28 -0500
Content-Disposition: inline
In-Reply-To: <1330091162-8141-8-git-send-email-danny.kukawka@bisect.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 24, 2012 at 02:45:58PM +0100, Danny Kukawka wrote:

> Print MAC/dev_addr via printk extended format specifier %pM
> instead of custom code.
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>

Acked-by: Lennert Buytenhek <kernel@wantstofly.org>
