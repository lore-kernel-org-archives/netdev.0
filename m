From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/20] [PATCH] [IPV6]: Add Kconfig to enable Mobile IPv6.
Date: Sun, 30 Jul 2006 15:43:00 -0700 (PDT)
Message-ID: <20060730.154300.42775765.davem@davemloft.net>
References: <11541658921982-git-send-email-nakam@linux-ipv6.org>
	<Pine.LNX.4.64.0607301819500.26424@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nakam@linux-ipv6.org, yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi,
	vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:47493
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751401AbWG3Wmu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 18:42:50 -0400
To: jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0607301819500.26424@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Sun, 30 Jul 2006 18:20:46 -0400 (EDT)

> The overall kernel config is getting very messed up because of all of 
> these selects.

The idea is that the user should be shielded from having to know what
random kernel internal subsystem is necessary in order for feature
"FOO" to even appear in their available kernel config selections.
