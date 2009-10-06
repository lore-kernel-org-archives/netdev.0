From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 05/15] igb: add combined function for
 setting rar and pool bits
Date: Tue, 06 Oct 2009 15:21:03 -0700 (PDT)
Message-ID: <20091006.152103.193470948.davem@davemloft.net>
References: <20091005163058.32487.10125.stgit@localhost.localdomain>
	<20091005163248.32487.51010.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47905
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933730AbZJFWVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 18:21:08 -0400
In-Reply-To: <20091005163248.32487.51010.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 05 Oct 2009 09:32:49 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch adds igb_rar_qsel which sets the mac address and pool bits for a
> given mac address in the receive address register table.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
