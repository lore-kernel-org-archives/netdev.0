From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Re: probably bug in drr scheduler, 2.6.29-rc5
Date: Fri, 27 Feb 2009 11:01:37 +0000
Message-ID: <20090227110137.GF4156@ff.dom.local>
References: <200902261745.28952.denys@visp.net.lb> <20090227101634.GD4156@ff.dom.local> <20090227.024613.141114390.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: denys@visp.net.lb, netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f176.google.com ([209.85.220.176]:33542 "EHLO
	mail-fx0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752385AbZB0LBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 06:01:45 -0500
Received: by fxm24 with SMTP id 24so985267fxm.37
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2009 03:01:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20090227.024613.141114390.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2009 at 02:46:13AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Fri, 27 Feb 2009 10:16:34 +0000
> 
> > pkt_sched: sch_drr: Fix oops in drr_change_class.
> > 
> > drr_change_class lacks a check for NULL of tca[TCA_OPTIONS], so oops
> > is possible.
> > 
> > Reported-by: Denys Fedoryschenko <denys@visp.net.lb>
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> Applied and queued up for -stable, thanks Jarek!

Hmm... if 2.6.29-rcX means -stable...

Thanks,
Jarek P. 
