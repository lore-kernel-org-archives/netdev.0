From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH -stable 01/02]: ipv6: reassembly: use seperate
	reassembly queues for conntrack and local delivery
Date: Thu, 17 Dec 2009 08:14:21 -0800
Message-ID: <20091217161421.GA31911@kroah.com>
References: <4B2A4B84.9070802@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org, Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:37060 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761484AbZLQQOy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2009 11:14:54 -0500
Content-Disposition: inline
In-Reply-To: <4B2A4B84.9070802@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2009 at 04:17:24PM +0100, Patrick McHardy wrote:
> The following two patches for -stable fix some defragmentation bugs
> in netfilter which can cause the kernel to crash in the bridge
> netfilter code.
> 
> Please apply, thanks.

To which -stable tree?  .32, .31, and/or .27?

thanks,

greg "tree juggler" k-h
