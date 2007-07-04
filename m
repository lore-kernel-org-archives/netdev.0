From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH -mm 6/9] netconsole: Update documentation for multiple target support
Date: Wed, 4 Jul 2007 09:01:28 -0500
Message-ID: <20070704140127.GD11115@waste.org>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in> <20070704110809.28520.1141.sendpatchset@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:48757 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759122AbXGDOCW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 10:02:22 -0400
Content-Disposition: inline
In-Reply-To: <20070704110809.28520.1141.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 04, 2007 at 04:38:09PM +0530, Satyam Sharma wrote:
> From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
> 
> [6/9] netconsole: Update documentation for multiple target support
> 
> ... and add a few useful general purpose tips as well while we're at it.

The tips are fine and should go in their own patch at the beginning of
the series. The docs for multiple interfaces should go either in the
patch that adds that (ideally) or after.

-- 
Mathematics is the supreme nostalgia of our time.
