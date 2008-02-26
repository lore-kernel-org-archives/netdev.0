From: Paul Mackerras <paulus@samba.org>
Subject: Re: [patch 0/6] pasemi_mac updates for 2.6.26
Date: Tue, 26 Feb 2008 20:49:58 +1100
Message-ID: <18371.57542.77446.443231@cargo.ozlabs.ibm.com>
References: <20080221025753.903665000@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, pasemi-linux@ozlabs.org,
	linuxppc-dev@ozlabs.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:42609 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757345AbYBZJuG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2008 04:50:06 -0500
In-Reply-To: <20080221025753.903665000@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Olof Johansson writes:

> Here's a set of updates for pasemi_mac for 2.6.26. Some of them touch
> the dma_lib in the platform code as well, but it's easier if it's all
> merged through netdev to avoid dependencies.
> 
> Major highlights are jumbo frame support and ethtool basics, the rest
> is mostly minor plumbing around it.

What route do you think these should take upstream?  I'm happy to take
them if Jeff is OK with that.

Paul.
