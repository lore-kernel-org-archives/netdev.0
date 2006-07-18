From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6][SCTP]: Extend /proc/net/sctp/snmp to provide more
 statistics.
Date: Mon, 17 Jul 2006 17:33:06 -0700 (PDT)
Message-ID: <20060717.173306.27784660.davem@davemloft.net>
References: <1153182337.4282.48.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:16260
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751270AbWGRAcr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jul 2006 20:32:47 -0400
To: sri@us.ibm.com
In-Reply-To: <1153182337.4282.48.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Mon, 17 Jul 2006 17:25:37 -0700

> [SCTP]: Extend /proc/net/sctp/snmp to provide more statistics.
> 
> This patch adds more statistics info under /proc/net/sctp/snmp
> that should be useful for debugging. The additional events that
> are counted now include timer expirations, retransmits, packet
> and data chunk discards.

This is a feature patch, the feature window of 2.6.18 is closed.

The rest are bug fixes, so I'll apply those, thanks.

