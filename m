From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Fix e100 on systems that have cache incoherent DMA
Date: Fri, 07 Sep 2007 19:24:53 -0400
Message-ID: <46E1DDC5.8040202@pobox.com>
References: <20070831205430.7209E46C20E@localhost> <46E17CD7.8080605@intel.com> <46E1B75C.6090208@roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Milton Miller <miltonm@bga.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	Scott Feldman <sfeldma@pobox.com>
To: David Acker <dacker@roinet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58428 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751283AbXIGXZR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 19:25:17 -0400
In-Reply-To: <46E1B75C.6090208@roinet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Acker wrote:
> Let me know if there is any other information I can provide you.  I will 
> look through the code to see what could be going on with your machine.  
> I will also look into reproducing these results with a newer kernel.  
> This may be tricky since compulab's patches are pretty stale and don't 
> always apply easily.


pktgen outputs for the various cases modified/unmodified[/others?] would 
be nice, if you have a spot of time.

	Jeff


