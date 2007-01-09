From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 1/10] cxgb3 - main header files
Date: Tue, 09 Jan 2007 08:28:59 -0800
Message-ID: <adamz4scgfo.fsf@cisco.com>
References: <20061220124125.6286.17148.stgit@localhost.localdomain>
	<45918CA4.3020601@garzik.org> <45A36C22.6010009@chelsio.com>
	<45A36E59.30500@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Divy Le Ray <divy@chelsio.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1-in.cisco.com ([171.71.176.70]:4641 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932208AbXAIQ3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 11:29:14 -0500
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <45A36E59.30500@garzik.org> (Jeff Garzik's message of "Tue, 09 Jan 2007 05:28:41 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > > You can grab the monolithic patch at this URL:
 > > http://service.chelsio.com/kernel.org/cxgb3.patch.bz2
 > 
 > this is in my queue, thanks.  Sorry I didn't indicate that earlier.

When do you plan to merge it?  For 2.6.20 or .21?

I'm trying to understand when the RDMA stuff that depends on the
ethernet driver can be merged.

Thanks,
  Roland
