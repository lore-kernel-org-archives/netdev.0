From: David Miller <davem@davemloft.net>
Subject: Re: [Security] [PATCH] infinite recursion in netlink
Date: Wed, 25 Apr 2007 23:31:21 -0700 (PDT)
Message-ID: <20070425.233121.41192812.davem@davemloft.net>
References: <20070426054842.GA18630@kroah.com>
	<20070426055259.GF2819@sequoia.sous-sol.org>
	<20070426062601.GH2819@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, security@kernel.org, netdev@vger.kernel.org,
	jaco@kroon.co.za, kuznet@ms2.inr.ac.ru,
	torvalds@linux-foundation.org
To: chrisw@sous-sol.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39863
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932985AbXDZGbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 02:31:14 -0400
In-Reply-To: <20070426062601.GH2819@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Wright <chrisw@sous-sol.org>
Date: Wed, 25 Apr 2007 23:26:01 -0700

> Working fine here.  Any chance you booted a stale kernel?
> If not, what's your nl_fib_input+0xe4.  Any chance that's
> actually in nl_fib_lookup?

I'm seriously hoping it's a stale kernel or similar,
because I can't account for it any other way :-)
