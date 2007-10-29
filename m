From: Jeff Garzik <jeff@garzik.org>
Subject: Re: e1000 and ICH9 hardware
Date: Mon, 29 Oct 2007 10:45:38 -0400
Message-ID: <4725F212.2030103@garzik.org>
References: <4725E125.4030103@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>
To: Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54064 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754832AbXJ2Opo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 10:45:44 -0400
In-Reply-To: <4725E125.4030103@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Drake wrote:
> Are there any plans to add ICH9 support to the e1000 driver (I note 
> there is a patch floating around), or is the intention that ICH9 users 
> all move to e1000e?

They all should use e1000e.

Further, in 2.6.25 or so, some e1000 PCI IDs will be moved to e1000e, 
and support removed in e1000.

e1000 is being frozen in time as "pre-PCI Express e1000's".

	Jeff



