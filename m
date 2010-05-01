From: David Miller <davem@davemloft.net>
Subject: Re: question re: net-2.6 and net-next-2.6 trees re: patch
 submission
Date: Fri, 30 Apr 2010 19:01:45 -0700 (PDT)
Message-ID: <20100430.190145.45137187.davem@davemloft.net>
References: <1272675194.21110.9.camel@Linuxdev3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dbrownell@users.sourceforge.net, rfiler@sierrawireless.com,
	netdev@vger.kernel.org
To: epasheva@sierrawireless.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41473
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757647Ab0EACBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 22:01:41 -0400
In-Reply-To: <1272675194.21110.9.camel@Linuxdev3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elina Pasheva <epasheva@sierrawireless.com>
Date: Fri, 30 Apr 2010 17:53:14 -0700

> If I submit a new driver to net-2.6 tree (e.g. sierra_net driver that
> was applied to net-2.6 tree) where do I submit subsequent patches for
> that driver - net-2.6 tree or net-next-2.6 tree? 

It depends upon the severity of the fix.

At this stage in the game on the most serious fixes are going
in, fixes for things that cause crashes and the like.  However
since a new driver we might be a little bit more lenient since
changes to a new driver can harm less people.
