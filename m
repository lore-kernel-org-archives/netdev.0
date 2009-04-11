From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] igb: fix unused external references introduced
 with sr-iov changes
Date: Sat, 11 Apr 2009 02:56:10 -0700 (PDT)
Message-ID: <20090411.025610.74733098.davem@davemloft.net>
References: <20090410084901.14739.20428.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58183
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750950AbZDKJ4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 05:56:19 -0400
In-Reply-To: <20090410084901.14739.20428.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 10 Apr 2009 01:49:02 -0700

> There were several unused external references added with the sr-iov
> enablement changes.  This patch changes all those references to static
> local references.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Because these three IGB/IGBVF patches are curing fallout from the igvf
driver recently merged, I'm adding them all directly to net-2.6

Thanks.
