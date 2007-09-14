From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: [PATCH v3] Make the pr_*() family of macros in kernel.h complete
Date: Fri, 14 Sep 2007 22:11:59 +0530
Message-ID: <a781481a0709140941w4ec76582j40ee53a189b99b05@mail.gmail.com>
References: <11896151802410-git-send-email-Emilian.Medve@Freescale.com>
	 <598D5675D34BE349929AF5EDE9B03E270155578C@az33exm24.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, i2c@lm-sensors.org,
	linux-omap-open-source@linux.omap.com
To: "Medve Emilian-EMMEDVE1" <Emilian.Medve@freescale.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758740AbXINQmW@vger.kernel.org>
In-Reply-To: <598D5675D34BE349929AF5EDE9B03E270155578C@az33exm24.fsl.freescale.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > -----Original Message-----
> > From: Medve Emilian-EMMEDVE1
> > Sent: Wednesday, September 12, 2007 11:40 AM
> > To: linux-kernel@vger.kernel.org; netdev@vger.kernel.org;
> > i2c@lm-sensors.org; linux-omap-open-source@linux.omap.com
> > Cc: Medve Emilian-EMMEDVE1

... no maintainer explicitly copied on the original mail who'd push this in.
Little thing, but LKML is too noisy, so you need to Cc: folks explicitly ...

> > Subject: [PATCH v3] Make the pr_*() family of macros in
> > kernel.h complete
> >
> > Other/Some pr_*() macros are already defined in kernel.h, but
> > pr_err() was defined
> > multiple times in several other places
> >
> > Signed-off-by: Emil Medve <Emilian.Medve@Freescale.com>

I think it's a useful cleanup, patch looks good to me ...

Reviewed-by: Satyam Sharma <satyam@infradead.org>

[ Original diff is at: http://lkml.org/lkml/diff/2007/9/12/182/1 ]
