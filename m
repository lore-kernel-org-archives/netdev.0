From: David Miller <davem@davemloft.net>
Subject: Re: RFC3927 ARP patch status?
Date: Fri, 02 Jun 2006 18:00:00 -0700 (PDT)
Message-ID: <20060602.180000.102575087.davem@davemloft.net>
References: <20060603003955.GJ549@progsoc.uts.edu.au>
	<20060602.174756.08320251.davem@davemloft.net>
	<4480DDF5.2080002@avtrex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wildfire@progsoc.uts.edu.au, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37299
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S932590AbWFCA75 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jun 2006 20:59:57 -0400
To: ddaney@avtrex.com
In-Reply-To: <4480DDF5.2080002@avtrex.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <ddaney@avtrex.com>
Date: Fri, 02 Jun 2006 17:55:17 -0700

> RFC3927 may be a mine field, but the only thing that has to be changed 
> in the kernel to support it is to somehow configure the arp driver to 
> broadcast unconditionally on certain interfaces.

Ok, I'd have to see the final patch after Herbert's suggestions
are taken into account.
