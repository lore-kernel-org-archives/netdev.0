From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] spidernet: remove unnecessary accesses to phy
Date: Fri, 11 May 2007 19:23:08 -0500
Message-ID: <20070512002308.GJ4452@austin.ibm.com>
References: <20070510171848.GD4452@austin.ibm.com> <4644D87C.5010903@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:56323 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755741AbXELAXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 20:23:23 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l4C0JnRN026676
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 20:19:49 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4C0NGiU195672
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 18:23:16 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4C0NG1w021142
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 18:23:16 -0600
Content-Disposition: inline
In-Reply-To: <4644D87C.5010903@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 11, 2007 at 04:56:28PM -0400, Jeff Garzik wrote:
> 
> applied.  

Thanks.

> Please move comments that do not belong in the permanent 
> record BELOW the "---".  See Documentation/SubmittingPatches for more info.

oops, sorry.

--linas

I've also got a multi-month old s2io patch that's in limbo. It was
ack'ed by an s2io maintainer, but otherwise fell through the cracks.
If you can find it and apply it, great, otherwise I'll resubmit 
"real soon now".

--linas
