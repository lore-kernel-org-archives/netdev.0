From: David Miller <davem@davemloft.net>
Subject: Re: [VLAN]: Fix SET_VLAN_INGRESS_PRIORITY_CMD ioctl
Date: Wed, 07 Nov 2007 01:31:50 -0800 (PST)
Message-ID: <20071107.013150.135485909.davem@davemloft.net>
References: <472C6882.2070201@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdkehn@yahoo.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38336
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753246AbXKGJbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 04:31:51 -0500
In-Reply-To: <472C6882.2070201@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Sat, 03 Nov 2007 13:24:34 +0100

> Fix a regression in 2.6.23. Candidate for -stable IMO.

Applied, and I'll queue it up for -stable, thanks!
