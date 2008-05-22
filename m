From: David Miller <davem@davemloft.net>
Subject: Re: [NETLINK]: Fix nla_parse_nested_compat() to call nla_parse()
 directly
Date: Thu, 22 May 2008 11:11:12 -0700 (PDT)
Message-ID: <20080522.111112.35704831.davem@davemloft.net>
References: <48356AE3.7050700@trash.net>
	<20080522.104913.231161238.davem@davemloft.net>
	<20080522110258.4cd23801@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, tgraf@suug.ch, davej@codemonkey.org.uk,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54678
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756426AbYEVSLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 14:11:17 -0400
In-Reply-To: <20080522110258.4cd23801@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 22 May 2008 11:02:58 -0700

> Pls, push this to stable as well.

Will do.
