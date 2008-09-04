From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Thu, 4 Sep 2008 10:21:56 -0700
Message-ID: <20080904102156.a40ec447.akpm@linux-foundation.org>
References: <20080903.161341.239039051.davem@davemloft.net>
	<200809041025.15277.rjw@sisk.pl>
	<48BFABE0.6050505@garzik.org>
	<200809041158.19929.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Ayaz Abdulla <aabdulla@nvidia.com>,
	David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	tomasw@gmail.com, yi.zhu@intel.com, linville@tuxdriver.com
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43451 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751124AbYIDRXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 13:23:20 -0400
In-Reply-To: <200809041158.19929.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 Sep 2008 11:58:18 +0200 "Rafael J. Wysocki" <rjw@sisk.pl> wrote:

> > > BTW, there are two regression fixes for forcedeth:
> > > 
> > > http://marc.info/?l=linux-kernel&m=121894389018584&w=4
> > > http://marc.info/?l=linux-kernel&m=121917167232014&w=4
> > > 
> > > that fix the regressions tracked as:
> > > 
> > > http://bugzilla.kernel.org/show_bug.cgi?id=11358
> > > http://bugzilla.kernel.org/show_bug.cgi?id=11361
> > > 
> > > respectively and both are more than 2 weeks old now.
> > > 
> > > Is there any chance to push them upstream or is there anything wrong with them?
> > 
> > Your patch is fine.  Since DaveM and I are gone this weekend, feel free 
> > to add "acked-by: jgarzik@redhat" and forward upstream to Linus and Andrew.
> 
> OK, thanks.
> 
> Andrew, this patch is currently in -mm as forcedeth-fix-kexec-regression.patch
> Could you please add the Jeff's ACK to it and push it to Linus?

yup, thanks.
