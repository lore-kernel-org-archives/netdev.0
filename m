From: David Miller <davem@davemloft.net>
Subject: Re: [Security] [PATCH] infinite recursion in netlink
Date: Thu, 26 Apr 2007 00:02:28 -0700 (PDT)
Message-ID: <20070426.000228.41635420.davem@davemloft.net>
References: <20070426062601.GH2819@sequoia.sous-sol.org>
	<20070425.233121.41192812.davem@davemloft.net>
	<20070426065151.GA4247@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chrisw@sous-sol.org, security@kernel.org, netdev@vger.kernel.org,
	jaco@kroon.co.za, kuznet@ms2.inr.ac.ru,
	torvalds@linux-foundation.org
To: greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41014
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933264AbXDZHCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:02:35 -0400
In-Reply-To: <20070426065151.GA4247@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg KH <greg@kroah.com>
Date: Wed, 25 Apr 2007 23:51:51 -0700

> Sorry for the false alarm, I have no idea what when wrong here.  Glad
> the bug is really fixed.

Nothing to be sorry about, it's great that you double checked
things even if it turned out to be a false alarm in the end.
