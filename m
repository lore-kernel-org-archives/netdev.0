From: wendy xiong <wendyx@us.ibm.com>
Subject: Re: [PATCH 5/5] NetXen: Fix link status messages
Date: Wed, 06 Jun 2007 14:46:04 -0500
Message-ID: <1181159164.25390.64.camel@wendyx.austin.ibm.com>
References: <200706011117.l51BHGYG004794@dut39.unminc.com>
	 <4662E390.6050904@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mithlesh Thukral <mithlesh@netxen.com>, netdev@vger.kernel.org,
	amitkale@netxen.com, netxenproj@linsyssoft.com, rob@netxen.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:50694 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751399AbXFFTqJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2007 15:46:09 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l56Jk6Y8031503
	for <netdev@vger.kernel.org>; Wed, 6 Jun 2007 15:46:06 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l56Jk6nV521302
	for <netdev@vger.kernel.org>; Wed, 6 Jun 2007 15:46:06 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l56Jk5vY010247
	for <netdev@vger.kernel.org>; Wed, 6 Jun 2007 15:46:06 -0400
In-Reply-To: <4662E390.6050904@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-06-03 at 11:51 -0400, Jeff Garzik wrote:
> Mithlesh Thukral wrote:
> > NetXen: Correct link status messages.
> > This patch will fix the problem of wrong link status messages
> > that were reported. 
> > 
> > Signed-off by: Wen Xiong <wenxiong@us.ibm.com>
> > Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
> > ---
> > 
> >  drivers/net/netxen/netxen_nic.h      |    1 +
> >  drivers/net/netxen/netxen_nic_init.c |   21 +++++++++++++--------
> >  drivers/net/netxen/netxen_nic_isr.c  |   23 +++++++++++++++++++++++
> >  3 files changed, 37 insertions(+), 8 deletions(-)
> 
> dropped due to previous patches being dropped
Hi Jeff, 

Thanks for your review the patch!
We are going to re-submit the patch with correct problem description.

Thanks,
wendy

