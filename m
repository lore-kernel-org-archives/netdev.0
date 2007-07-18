From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: Re: [PATCH] net/, drivers/net/ , missing EXPERIMENTAL in menus
Date: Wed, 18 Jul 2007 16:23:09 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0707181620460.13912@localhost.localdomain>
References: <469E75AA.7040109@pimpmylinux.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Gabriel C <crazy@pimpmylinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:50394 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757771AbXGRUZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 16:25:12 -0400
In-Reply-To: <469E75AA.7040109@pimpmylinux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Jul 2007, Gabriel C wrote:

> Everything 'depends on' EXPERIMENTAL should be marked as such,
> visible in the menus.

rather than add all that extraneous dreck to the Kconfig files, i
*really* wish folks would give serious thought to my earlier
suggestion about a "maturity level" attribute that could be used to
not only add a parenthesized maturity level during display, but could
also be used to activate/deactivate entire levels in one operation.

there's no point adding all that redundant content when it can all be
done automatically.

rday
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================
