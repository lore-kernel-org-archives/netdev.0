From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Add VLAN (802.1q) support to sis900 driver
Date: Fri, 23 Nov 2007 22:11:31 -0500
Message-ID: <47479663.8080400@garzik.org>
References: <20060417112553.GA22890@renditai.milesteg.arr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44390 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754098AbXKXDLd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 22:11:33 -0500
Received: from cpe-069-134-071-233.nc.res.rr.com ([69.134.71.233] helo=core.yyz.us)
	by mail.dvmed.net with esmtpsa (Exim 4.63 #1 (Red Hat Linux))
	id 1IvlQa-0006qK-AA
	for netdev@vger.kernel.org; Sat, 24 Nov 2007 03:11:32 +0000
In-Reply-To: <20060417112553.GA22890@renditai.milesteg.arr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniele Venzano wrote:
> The attached patch adds support for VLANs to the sis900 driver and bumps
> the version number. It is based on an old (2003) patch for the 2.4
> series by Hamid Hashemi Golpayegani. It applies on top of 2.6.16(.5).
> I have one report that it works and behaves as intended.
> Please review and consider for inclusion.
> 
> Signed-off-by: Daniele Venzano <venza@brownhat.org>

I just found this buried in my inbox... can you resubmit for the latest 
kernel?


