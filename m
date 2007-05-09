From: David Miller <davem@davemloft.net>
Subject: Re: [IPV6] send ICMPv6 error on scope violations
Date: Wed, 09 May 2007 13:54:35 -0700 (PDT)
Message-ID: <20070509.135435.32719359.davem@davemloft.net>
References: <OFA075DC7D.6AB1CB33-ON882572D6.006CBBA4-882572D6.006D635E@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37260
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751690AbXEIUye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 16:54:34 -0400
In-Reply-To: <OFA075DC7D.6AB1CB33-ON882572D6.006CBBA4-882572D6.006D635E@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Stevens <dlstevens@us.ibm.com>
Date: Wed, 9 May 2007 13:55:15 -0600

> When an IPv6 router is forwarding a packet with a link-local scope source
> address off-link, RFC 4007 requires it to send an ICMPv6 destination
> unreachable with code 2 ("not neighbor"), but Linux doesn't. Fix below.
> 
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

Applied, thanks David.
