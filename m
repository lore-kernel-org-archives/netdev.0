From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: set congestion default through Kconfig
Date: Tue, 19 Sep 2006 12:33:52 -0700 (PDT)
Message-ID: <20060919.123352.124082859.davem@davemloft.net>
References: <20060918.115309.88343320.davem@davemloft.net>
	<20060918195224.GA26585@outpost.ds9a.nl>
	<20060918214104.3824a2e2@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bert.hubert@netherlabs.nl, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:49046
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751059AbWISTdr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 15:33:47 -0400
To: shemminger@osdl.org
In-Reply-To: <20060918214104.3824a2e2@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ok, I really give up, after adding the missing semicolon I now
get this:

net/ipv4/sysctl_net_ipv4.c:136: warning: initialization from incompatible pointer type

This is getting rediculious.

Folks, don't post patches which are not "request for comments"
explicitly in the subject line without testing the build, ever!

