From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 12/15] igb: move the generic copper link
 setup code into e1000_phy.c
Date: Tue, 06 Oct 2009 15:21:49 -0700 (PDT)
Message-ID: <20091006.152149.252126428.davem@davemloft.net>
References: <20091005163058.32487.10125.stgit@localhost.localdomain>
	<20091005163502.32487.1493.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47933
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933820AbZJFWVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 18:21:54 -0400
In-Reply-To: <20091005163502.32487.1493.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 05 Oct 2009 09:35:03 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch moves the generic portion of the copper link setup into a
> seperate function in e1000_phy.c.  This helps to reduce the size of
> copper_link_setup_82575 and make it a bit more readable.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
