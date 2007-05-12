From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] spidernet: remove unnecessary accesses to phy
Date: Fri, 11 May 2007 20:13:37 -0500
Message-ID: <20070512011337.GL4452@austin.ibm.com>
References: <20070510171848.GD4452@austin.ibm.com> <4644D87C.5010903@garzik.org> <20070512002308.GJ4452@austin.ibm.com> <46450C24.3040000@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:44654 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755129AbXELBNk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 21:13:40 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4C1Ddfv026367
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 21:13:39 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4C1DdVM559518
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 21:13:39 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4C1Dc5O005001
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 21:13:39 -0400
Content-Disposition: inline
In-Reply-To: <46450C24.3040000@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 11, 2007 at 08:36:52PM -0400, Jeff Garzik wrote:
> Linas Vepstas wrote:
> >
> >I've also got a multi-month old s2io patch that's in limbo. It was
> >ack'ed by an s2io maintainer, but otherwise fell through the cracks.
> >If you can find it and apply it, great, otherwise I'll resubmit 
> >"real soon now".
> 
> If you don't hear about a patch in over 14 days, you may assume I've 
> deleted it from my mbox queue.

Next week then. yow! I don't have enough disk space for all this stuff...

--linas
