From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 0/4]:  powerpc/cell spidernet ethernet driver fixes
Date: Fri, 11 Aug 2006 14:31:02 -0500
Message-ID: <20060811193102.GN10638@austin.ibm.com>
References: <20060811170337.GH10638@austin.ibm.com> <20060811174439.GA30191@mars.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, James K Lewis <jklewis@us.ibm.com>,
	Utz Bacher <utz.bacher@de.ibm.com>,
	Jens Osterkamp <Jens.Osterkamp@de.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:56719 "EHLO
	e32.co.us.ibm.com") by vger.kernel.org with ESMTP id S932241AbWHKTbF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 15:31:05 -0400
To: Sam Ravnborg <sam@ravnborg.org>
Content-Disposition: inline
In-Reply-To: <20060811174439.GA30191@mars.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 11, 2006 at 07:44:39PM +0200, Sam Ravnborg wrote:
> > 
> > These have been well-tested over the last few weeks. Please apply. 
> Hi Linas.
> Just noticed a nit-pick detail.
> The general rule is to add your Signed-off-by: at the bottom of the
> patch, so the top-most Signed-of-by: is also the original author whereas
> the last Signed-of-by: is the one that added this patch to the kernel.

I put my name at the top when I was the primary author. 
I put Jim's name at the top when he was the primary author. 

Both names are there because I sat in Jim's office and used
his keyboard. I got him to compile and run the tests on
his hardware, and we'd then debate the results.

> Likewise you add Cc: before your Signed-off-by: line.

The patches I ave from akpm have the CC's after the 
signed-off by line, not before.

--linas
