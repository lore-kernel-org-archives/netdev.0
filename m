From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] New Qlogic 10Gb Ethernet driver for 2.6.28
Date: Thu, 21 Aug 2008 20:48:03 +0100
Message-ID: <20080821194802.GR7908@solarflare.com>
References: <20080821185402.GD31526@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: jeff@garzik.org, netdev@vger.kernel.org, Linux-Driver@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:40364 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752038AbYHUTsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 15:48:10 -0400
Content-Disposition: inline
In-Reply-To: <20080821185402.GD31526@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ron Mercer wrote:
> Hi Jeff,
> 
> Please find our new 10Gb ethernet driver at the following site:
> 
> ftp://ftp.qlogic.com/outgoing/linux/network/linux/upstream/qlge
> 
> There are two files at this location:
> qlge-aug212008.patch - A full patch that is buildable on the latest netdev/upstream kernel.
> qlge-aug212008.tar.bz2 - A zip file of the source code at drivers/net/qlge/*
> 
> We are targeting this driver for 2.6.28 release.  We look forward to any and all comments.
[...]

Can you break up the patch into logical chunks and post them to netdev?
(The message limit is 100 K.)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
