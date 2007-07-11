From: Joel Becker <Joel.Becker@oracle.com>
Subject: Re: [PATCH v2 -mm 4/9] netconsole: Add some useful tips to documentation
Date: Tue, 10 Jul 2007 21:20:37 -0700
Message-ID: <20070711042036.GR1011@tasint.org>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in> <20070710091941.23907.45658.sendpatchset@cselinux1.cse.iitk.ac.in> <20070710094142.GM11115@waste.org> <200707101434.39938.jesper.juhl@gmail.com> <Pine.LNX.4.64.0707110256220.2445@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Juhl <jesper.juhl@gmail.com>,
	Matt Mackall <mpm@selenic.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:17422 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751598AbXGKEVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 00:21:15 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707110256220.2445@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 11, 2007 at 03:40:22AM +0530, Satyam Sharma wrote:
> IMHO something that mentions /proc/sys/kernel/printk would be better.
> 
> You don't need to have built with SysRq support for that, it's clearly
> more flexible than the ignore_loglevel option and wouldn't require a
> reboot either. I'll send out an updated patch shortly.

	Why not dmesg -n?  We've been using that for years.  Or is there
some extra change in /proc/sys/kernel/printk?

Joel

-- 

"Against stupidity the Gods themselves contend in vain."
	- Friedrich von Schiller

Joel Becker
Principal Software Developer
Oracle
E-mail: joel.becker@oracle.com
Phone: (650) 506-8127
