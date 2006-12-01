From: Don Fry <brazilnut@us.ibm.com>
Subject: Re: [PATCH 0/5 addendum] NetXen
Date: Thu, 30 Nov 2006 16:27:43 -0800
Message-ID: <20061201002743.GA17257@us.ibm.com>
References: <20061130185602.GA32337@us.ibm.com> <456F7436.8060500@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, amitkale@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com, sanjeev@netxen.com,
	wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:2261 "EHLO e36.co.us.ibm.com")
	by vger.kernel.org with ESMTP id S1031645AbWLAA1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 19:27:48 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kB10Rmtj007855
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 19:27:48 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB10RlRS553748
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 17:27:47 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB10Rlh3016964
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 17:27:47 -0700
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <456F7436.8060500@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 30, 2006 at 07:15:50PM -0500, Jeff Garzik wrote:
> Don Fry wrote:
> >The NetXen patches fix many problems in the current #upstream version of
> >the driver.  It has warts and probably lots of bugs still, but it is
> >better than what is queued for mainline inclusion at this time.  Please
> >apply to 2.6.20.
> 
> Please resync with netdev#upstream, and update for comments on netdev...
> 
> 	Jeff

I think I am up to date with netdev#upstream.  Maybe I am pointed at the
wrong place.  Is the correct git tree at?
http://www.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git/

and then to get to the upstream branch I do
git-checkout upstream

-- 
Don Fry
brazilnut@us.ibm.com
