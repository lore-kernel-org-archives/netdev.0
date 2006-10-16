From: Patrick McHardy <kaber@trash.net>
Subject: Re: Patch to remove masq/NAT in description of IP6_NF_IPTABLES in
 ipv6/netfilter/Kconfig
Date: Mon, 16 Oct 2006 09:05:41 +0200
Message-ID: <45332F45.9020207@trash.net>
References: <45332E45.10207@bieringer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:12451 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1030314AbWJPHFp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Oct 2006 03:05:45 -0400
To: Peter Bieringer <pb@bieringer.de>
In-Reply-To: <45332E45.10207@bieringer.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Bieringer wrote:
> afaik, NAT (and therefore masquerading also) is left out by design in
> IPv6, looks like a copy&paste issue.
> 
> Patch attached to fix this.

Applied, thanks. But please sign off future patches.
