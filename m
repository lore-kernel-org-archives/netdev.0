From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 3/3] igbvf: fix memory leak when ring size
 changed while interface down
Date: Mon, 26 Oct 2009 16:09:26 -0700 (PDT)
Message-ID: <20091026.160926.203867701.davem@davemloft.net>
References: <20091026213147.9993.9778.stgit@localhost.localdomain>
	<20091026213225.9993.25681.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55313
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754535AbZJZXJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 19:09:02 -0400
In-Reply-To: <20091026213225.9993.25681.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 26 Oct 2009 14:32:25 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch resolves a memory leak which occurs while changing the ring size
> while the interface is down.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
