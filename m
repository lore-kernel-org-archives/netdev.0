From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCHv2] smsc911x: add irq_flags in smsc911x_platform_config.
Date: Wed, 14 Jan 2009 10:14:38 +0000
Message-ID: <20090114101438.GC22976@n2100.arm.linux.org.uk>
References: <1231916280-7391-1-git-send-email-stanley.miao@windriver.com> <OF8C316D93.937F4899-ON8025753E.0030604F-8025753E.003106B3@smsc.com> <20090114100550.GA22976@n2100.arm.linux.org.uk> <20090114.021124.222393549.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve.Glendinning@smsc.com, stanley.miao@windriver.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:59095 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753240AbZANKOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 05:14:52 -0500
Content-Disposition: inline
In-Reply-To: <20090114.021124.222393549.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 02:11:24AM -0800, David Miller wrote:
> From: Russell King - ARM Linux <linux@arm.linux.org.uk>
> Date: Wed, 14 Jan 2009 10:05:50 +0000
> 
> > I can't really comment because it seems that there's no way to work out
> > what patch you're acking.
> 
> http://patchwork.ozlabs.org/patch/18386/

Ah, yes, it's doing as I thought.  I'll nak it then.

There's really no need for this driver to start doing this a different way
to the rest of the kernel.
