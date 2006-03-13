From: "Leech, Christopher" <christopher.leech@intel.com>
Subject: RE: [PATCH 3/8] [I/OAT] Setup the networking subsystem as a DMA client
Date: Mon, 13 Mar 2006 14:12:12 -0800
Message-ID: <E3A930D59AFC3345AEBA35189102A8A6060E15E9@orsmsx404.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932492AbWCMWMY@vger.kernel.org>
Content-class: urn:content-classes:message
To: "Andrew Morton" <akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >  +#ifdef CONFIG_NET_DMA
> >  +#include <linux/dmaengine.h>
> >  +#endif
> 
> There are still a number of instances of this in the patch 
> series.  Did you
> decide to keep the ifdefs in there for some reason?

No, I just missed them in header files.  Thanks. 
