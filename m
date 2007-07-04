From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: Re: [PATCH -mm 6/9] netconsole: Update documentation for multiple
 target support
Date: Wed, 4 Jul 2007 23:41:51 +0530 (IST)
Message-ID: <Pine.LNX.4.64.0707042340240.757@cselinux1.cse.iitk.ac.in>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070704110809.28520.1141.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070704140127.GD11115@waste.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:44428 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753882AbXGDRu1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 13:50:27 -0400
In-Reply-To: <20070704140127.GD11115@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Matt,

On Wed, 4 Jul 2007, Matt Mackall wrote:
> On Wed, Jul 04, 2007 at 04:38:09PM +0530, Satyam Sharma wrote:
> > From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
> > 
> > [6/9] netconsole: Update documentation for multiple target support
> > 
> > ... and add a few useful general purpose tips as well while we're at it.
> 
> The tips are fine and should go in their own patch at the beginning of
> the series. The docs for multiple interfaces should go either in the
> patch that adds that (ideally) or after.

Ok, will do that in the next iteration -- along with the change to get
rid of the redundant ->dev_status member, as you mentioned.

Thanks a lot for reviewing this, Matt.

Satyam
