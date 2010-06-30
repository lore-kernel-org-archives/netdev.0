From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/4] e1000e: suppress compile warnings on
 certain archs
Date: Tue, 29 Jun 2010 23:14:50 -0700 (PDT)
Message-ID: <20100629.231450.85407834.davem@davemloft.net>
References: <20100630040959.8652.31147.stgit@localhost.localdomain>
	<20100630041228.8652.61761.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59109
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752051Ab0F3GOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 02:14:37 -0400
In-Reply-To: <20100630041228.8652.61761.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 29 Jun 2010 21:12:30 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Commit 84f4ee902ad3ee964b7b3a13d5b7cf9c086e9916 causes compile warnings on
> architectures that have unsigned long long's that are not 64-bit, e.g.
> ia64.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
