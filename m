From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] [IPV6]: Remove ndiscs rt6_lock dependency
Date: Wed, 26 Jul 2006 16:34:16 -0700 (PDT)
Message-ID: <20060726.163416.48672195.davem@davemloft.net>
References: <20060726221849.188750063@postel.suug.ch>
	<20060726.152845.71540437.davem@davemloft.net>
	<44C7FBEB.30708@mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:46748
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750812AbWGZXeG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 19:34:06 -0400
To: tgohad@mvista.com
In-Reply-To: <44C7FBEB.30708@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tushar Gohad <tgohad@mvista.com>
Date: Wed, 26 Jul 2006 16:34:03 -0700

> Are these changes scheduled to go into 2.6.18-rcX or 2.6.19?

Since the feature freeze is frozen, net-2.6.19 is where it
will likely go.
