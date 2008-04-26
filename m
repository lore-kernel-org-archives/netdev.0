From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Sat, 26 Apr 2008 02:07:46 -0700 (PDT)
Message-ID: <20080426.020746.82568920.davem@davemloft.net>
References: <20080425.233131.247778262.davem@davemloft.net>
	<OF9BF48C5B.EB7BA30D-ON88257437.00269450-88257437.0027B15D@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55512
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752083AbYDZJHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 05:07:47 -0400
In-Reply-To: <OF9BF48C5B.EB7BA30D-ON88257437.00269450-88257437.0027B15D@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Stevens <dlstevens@us.ibm.com>
Date: Sat, 26 Apr 2008 00:13:34 -0700

> The protocol setsockopt functions are already external, so I'd
> expect compat would need any CONFIG guarding. Am I missing
> something?

Fair enough, code this up so I can see what it looks like.

Thanks for all of this work David!
