From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH] net: NEWEMAC: Remove "rgmii-interface" from rgmii
	matching table
Date: Wed, 16 Jan 2008 20:39:41 +1100
Message-ID: <20080116093941.GA7393@localhost.localdomain>
References: <1200476230-14026-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38873 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751308AbYAPJk3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2008 04:40:29 -0500
Content-Disposition: inline
In-Reply-To: <1200476230-14026-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 16, 2008 at 10:37:10AM +0100, Stefan Roese wrote:
> With the removal the the "rgmii-interface" device_type property from the
> dts files, the newemac driver needs an update to only rely on compatible
> property.

In fact, this patch should go in before the one changing the dts
files.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson
