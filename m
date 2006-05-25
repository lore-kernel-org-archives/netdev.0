From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/3] bridge patches for 2.6.18
Date: Thu, 25 May 2006 16:00:29 -0700 (PDT)
Message-ID: <20060525.160029.44095378.davem@davemloft.net>
References: <20060524171216.706750000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28370
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S964860AbWEYXAY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 19:00:24 -0400
To: shemminger@osdl.org
In-Reply-To: <20060524171216.706750000@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 24 May 2006 10:12:16 -0700

> Some stuff for 2.6.18. The most important is adding netlink
> support for managing interfaces; this allows building STP
> as an application.

Applied to net-2.6.18, thanks Stephen.
