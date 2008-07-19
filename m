From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: sendfile() broken with 2.6.26 + Apache 2 ?
Date: Sat, 19 Jul 2008 09:52:15 -0500
Message-ID: <20080719095215.375ae9a2@osprey.hogchain.net>
References: <487CD7A7.2080800@jeffray.co.uk>
	<4881DEB2.8030508@bellsouth.net>
	<4881E0BD.4060608@jeffray.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ian Jeffray <ian@jeffray.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost04.isp.att.net ([204.127.217.104]:47551 "EHLO
	fmailhost04.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754571AbYGSOwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 10:52:17 -0400
In-Reply-To: <4881E0BD.4060608@jeffray.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 19 Jul 2008 13:40:29 +0100
Ian Jeffray <ian@jeffray.co.uk> wrote:

> Hi Jay,
> 
> > Can you please enable verbose logging
> > 
> > echo 8 > /proc/sys/kernel/printk
> > ethtool -s eth0 msglvl 0xffff
> > 
> > and see if the driver issues any error messages as the file is
> > transferred?
> 
> Nothing, sorry.

Can you please provide a complete dmesg for the sender?

Thanks.
