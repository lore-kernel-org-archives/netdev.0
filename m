From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 14/15] igb: add additional error handling
 to the phy code
Date: Tue, 06 Oct 2009 15:22:00 -0700 (PDT)
Message-ID: <20091006.152200.93401827.davem@davemloft.net>
References: <20091005163058.32487.10125.stgit@localhost.localdomain>
	<20091005163541.32487.2008.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47940
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933825AbZJFWWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 18:22:05 -0400
In-Reply-To: <20091005163541.32487.2008.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 05 Oct 2009 09:35:42 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This update adds additional exception handling to the phy code to handle
> situations where it may be called incorrectly.  In addition it adds some
> bounds checking to the cable length checks to prevent an array overrun in
> the event that the hardware returned a different value than expected.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
