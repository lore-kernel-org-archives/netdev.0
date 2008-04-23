From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [E1000-devel] [PATCH 4/8] e1000e: lower ring minimum size to
 64
Date: Wed, 23 Apr 2008 11:12:46 -0700
Message-ID: <480F7C1E.4090900@intel.com>
References: <20080423180900.24972.84015.stgit@localhost.localdomain> <20080423180919.24972.67080.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:3360 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752784AbYDWSNA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2008 14:13:00 -0400
In-Reply-To: <20080423180919.24972.67080.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auke Kok wrote:
> The lower limit of 80 descriptors in the ring is only valid for
> one older 8254x chipset. All e1000e devices can use as low as
> 64 descriptors.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

Jeff,

patch #1-4 are RESENDS, where I omitted the VLAN/TSO fix that PJ will respin.
patch 5-8 are trivial patches (partial RESENDS) that I did not see merged yet and
I could not find in any of your trees ATM. apologies if I sound pushy - just
making sure these don't fall through the cracks ;)

Cheers

Auke
