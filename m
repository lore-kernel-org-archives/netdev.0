From: David Miller <davem@davemloft.net>
Subject: Re: TCP event tracking via netlink...
Date: Wed, 02 Jan 2008 00:22:27 -0800 (PST)
Message-ID: <20080102.002227.67777942.davem@davemloft.net>
References: <Pine.LNX.4.64.0712051533050.3119@kivilampi-30.cs.helsinki.fi>
	<20071206.023346.256200942.davem@davemloft.net>
	<20071206092312.79a83208@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59871
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752590AbYABIW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 03:22:28 -0500
In-Reply-To: <20071206092312.79a83208@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 6 Dec 2007 09:23:12 -0800

> Tools and scripts for testing that generate graphs are at:
> 	git://git.kernel.org/pub/scm/tcptest/tcptest

Did you move it somewhere else?

davem@sunset:~/src/GIT$ git clone git://git.kernel.org/pub/scm/tcptest/tcptest
Initialized empty Git repository in /home/davem/src/GIT/tcptest/.git/
fatal: The remote end hung up unexpectedly
fetch-pack from 'git://git.kernel.org/pub/scm/tcptest/tcptest' failed.
