From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 1/2]: [NET]: Supporting UDP-Lite (RFC 3828) in Linux
Date: Wed, 15 Nov 2006 00:45:00 -0800 (PST)
Message-ID: <20061115.004500.93385098.davem@davemloft.net>
References: <200611140848.45863@strip-the-willow>
	<20061114.201959.112851807.davem@davemloft.net>
	<200611150758.17769@strip-the-willow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:15031
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S966692AbWKOIo6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Nov 2006 03:44:58 -0500
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <200611150758.17769@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 15 Nov 2006 07:58:17 +0000

> [NET/IPv4]: Make udp_push_pending_frames static
>             udp_push_pending_frames is only referenced within
>             net/ipv4/udp.c and hence can remain static.
> 
> Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>

Applied, thanks Gerrit.
