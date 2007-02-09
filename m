From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] MAINTAINERS: no DMFE maintainer
Date: Fri, 9 Feb 2007 14:54:04 -0800
Message-ID: <20070209145404.d317a496.randy.dunlap@oracle.com>
References: <20070209143106.9dc30c9b.randy.dunlap@oracle.com>
	<45CCF978.40006@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, tori@unhappy.mine.nu,
	Levitsky Maxim <maximlevitsky@yahoo.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:49623 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423360AbXBIW7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 17:59:00 -0500
In-Reply-To: <45CCF978.40006@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 09 Feb 2007 17:45:12 -0500 Jeff Garzik wrote:

> Randy Dunlap wrote:
> > From: Randy Dunlap <randy.dunlap@oracle.com>
> > 
> > Tobias wrote that he no longer maintains this driver and requested
> > to be removed from MAINTAINERS.
> > 
> > Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> > ---
> >  MAINTAINERS |    4 +---
> >  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> 
> Levitsky Maxim <maximlevitsky@yahoo.com> just posted a bunch of patches 
> to the dmfe driver, maybe you could ping him?

Hi Maxim,
What do you think about this patch to the MAINTAINERS file
based on your recent DMFE patch history?

---

From: Randy Dunlap <randy.dunlap@oracle.com>

Tobias wrote that he no longer maintains this driver and requested
to be removed from MAINTAINERS.  However, Levitsky Maxim has been
active on DMFE recently.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 MAINTAINERS |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-2.6.20-git5.orig/MAINTAINERS
+++ linux-2.6.20-git5/MAINTAINERS
@@ -1112,8 +1112,8 @@ T:	git kernel.org:/pub/scm/linux/kernel/
 S:	Supported
 
 DAVICOM FAST ETHERNET (DMFE) NETWORK DRIVER
-P:	Tobias Ringstrom
-M:	tori@unhappy.mine.nu
+P:	Levitsky Maxim
+M:	maximlevitsky@yahoo.com
 L:	netdev@vger.kernel.org
 S:	Maintained
 
