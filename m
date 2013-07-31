From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [E1000-devel] [PATCH] e100: dump small buffers via %*phC
Date: Wed, 31 Jul 2013 15:20:05 +0300
Message-ID: <1375273205.31118.68.camel@smile>
References: <1374751459-17994-1-git-send-email-andriy.shevchenko@linux.intel.com>
	 <1374837154.32309.1.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	e1000-devel@lists.sourceforge.net
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:15743 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751827Ab3GaMU0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 08:20:26 -0400
In-Reply-To: <1374837154.32309.1.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-07-26 at 04:12 -0700, Jeff Kirsher wrote: 
> On Thu, 2013-07-25 at 14:24 +0300, Andy Shevchenko wrote:
> > There is nice specifier in kernel that allows us to print small
> > buffers easily.
> > 
> > Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> > ---
> >  drivers/net/ethernet/intel/e100.c | 15 ++++++---------
> >  1 file changed, 6 insertions(+), 9 deletions(-) 
> 
> Thanks, I appreciate you sending this again...
> 
> I already have this patch queued up for upstream and it will be in the
> next series I send.

Oh, sorry for resending.
I cleared up my queue after rebasing to recent linux-next, where the
patch is not appeared yet, that's why duplicate was created.


-- 
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
