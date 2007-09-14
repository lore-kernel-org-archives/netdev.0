From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH v3] Make the pr_*() family of macros in kernel.h
 complete
Date: Fri, 14 Sep 2007 10:13:29 -0700
Message-ID: <20070914101329.60d42ca7.randy.dunlap@oracle.com>
References: <11896151802410-git-send-email-Emilian.Medve@Freescale.com>
	<598D5675D34BE349929AF5EDE9B03E270155578C@az33exm24.fsl.freescale.net>
	<a781481a0709140941w4ec76582j40ee53a189b99b05@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Medve Emilian-EMMEDVE1" <Emilian.Medve@freescale.com>,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, i2c@lm-sensors.org,
	linux-omap-open-source@linux.omap.com
To: "Satyam Sharma" <satyam.sharma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:20633 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752367AbXINRSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 13:18:32 -0400
In-Reply-To: <a781481a0709140941w4ec76582j40ee53a189b99b05@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Sep 2007 22:11:59 +0530 Satyam Sharma wrote:

> > > -----Original Message-----
> > > From: Medve Emilian-EMMEDVE1
> > > Sent: Wednesday, September 12, 2007 11:40 AM
> > > To: linux-kernel@vger.kernel.org; netdev@vger.kernel.org;
> > > i2c@lm-sensors.org; linux-omap-open-source@linux.omap.com
> > > Cc: Medve Emilian-EMMEDVE1
> 
> ... no maintainer explicitly copied on the original mail who'd push this in.
> Little thing, but LKML is too noisy, so you need to Cc: folks explicitly ...
> 
> > > Subject: [PATCH v3] Make the pr_*() family of macros in
> > > kernel.h complete
> > >
> > > Other/Some pr_*() macros are already defined in kernel.h, but
> > > pr_err() was defined
> > > multiple times in several other places
> > >
> > > Signed-off-by: Emil Medve <Emilian.Medve@Freescale.com>
> 
> I think it's a useful cleanup, patch looks good to me ...
> 
> Reviewed-by: Satyam Sharma <satyam@infradead.org>

I like it too.

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

(since I still haven't seen reviewed-by in SubmittingPatches)

> [ Original diff is at: http://lkml.org/lkml/diff/2007/9/12/182/1 ]

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
