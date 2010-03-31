From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] igb: add per-packet timestamping
Date: Tue, 30 Mar 2010 23:42:49 -0700 (PDT)
Message-ID: <20100330.234249.190071261.davem@davemloft.net>
References: <20100326213545.19028.21468.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	nicholasx.d.nunley@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50956
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932893Ab0CaGmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 02:42:47 -0400
In-Reply-To: <20100326213545.19028.21468.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 26 Mar 2010 14:36:47 -0700

> From: Nick Nunley <nicholasx.d.nunley@intel.com>
> 
> This patch adds support for per-packet timestamping for the
> 82580 adapter. The rx timestamp code is also pulled out of the
> inlined rx hotpath and instead moved to a seperate function.
> 
> This version adds a comment explaining the per-packet timestamping
> code added to igb_hwtstamp_ioctl().
> 
> Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
