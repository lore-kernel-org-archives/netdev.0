From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100 rx: or s and
 el bits)
Date: Thu, 17 May 2007 20:47:02 -0700
Message-ID: <464D21B6.2000208@intel.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net> <46375664.8030701@roinet.com> <4638F2B2.2000103@roinet.com> <463BA906.30205@roinet.com> <85f07fc58d5ed2147d5214d0f0b4fe32@bga.com> <4648A9DF.6030001@roinet.com> <464D074F.20400@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Acker <dacker@roinet.com>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Milton Miller <miltonm@bga.com>,
	e1000-devel@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Scott Feldman <sfeldma@pobox.com>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:39773 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758148AbXERDrH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2007 23:47:07 -0400
In-Reply-To: <464D074F.20400@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Can you resend against the latest kernel (2.6.22-rc1)?
> 
> And what does Intel think?

I'm expecting at least a reply from Milton as the patch was sent to him. I 
haven't yet tested it but will certainly do so. At first glance it looks OK, and 
I'll try to put it under my colleague's noses who know e100 best.

A resend against 2.6.22-rc1 would be nice.

Auke
