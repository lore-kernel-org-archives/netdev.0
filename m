From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] iproute2: allow IPv6 addresses for l2tp local and
 remote parameters
Date: Tue, 22 May 2012 14:26:40 -0700
Message-ID: <20120522142640.2d144973@nehalam.linuxnetplumber.net>
References: <1335882323-6219-1-git-send-email-jchapman@katalix.com>
	<1335882323-6219-2-git-send-email-jchapman@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Chris Elston <celston@katalix.com>
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42709 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750819Ab2EVV0p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2012 17:26:45 -0400
In-Reply-To: <1335882323-6219-2-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  1 May 2012 15:25:22 +0100
James Chapman <jchapman@katalix.com> wrote:

> From: Chris Elston <celston@katalix.com>
> 
> Adds support for parsing IPv6 addresses to the parameters local and
> remote in the l2tp commands. Requires netlink attributes L2TP_ATTR_IP6_SADDR
> and L2TP_ATTR_IP6_DADDR, added in a required kernel patch already submitted
> to netdev.
> 
> Also enables printing of IPv6 addresses returned by the L2TP_CMD_TUNNEL_GET
> request.
> 
> Signed-off-by: Chris Elston <celston@katalix.com>
> Signed-off-by: James Chapman <jchapman@katalix.com>

Applied. Since l2tp ipv6 is part of 3.5 merge.
