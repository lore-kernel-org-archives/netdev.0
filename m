From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [-mm patch] one e1000 driver should be enough for everyone
Date: Wed, 25 Jul 2007 11:23:00 -0400
Message-ID: <46A76AD4.7000101@garzik.org>
References: <20070725040304.111550f4.akpm@linux-foundation.org> <20070725133650.GB3572@stusta.de> <46A754C7.9080004@garzik.org> <20070725144615.GC3572@stusta.de> <46A7669C.5010104@garzik.org> <46A76A66.9000304@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38529 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757044AbXGYPXE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2007 11:23:04 -0400
In-Reply-To: <46A76A66.9000304@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> I'm working on "e1000e" right now...

Cool :)


> I'll submit it with only ich9 id's at first, but it will be able to 
> drive (sysfs bind) to some other devices too. This allows me to keep an 
> eye out on the future structure that I want to give it without removing 
> too much code that I might then later have to add back.

Sounds good to me...

	Jeff



