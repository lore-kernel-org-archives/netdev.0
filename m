From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] igb: modify register test for i350 to
 reflect read only bits in RDLEN/TDLEN
Date: Tue, 13 Apr 2010 02:59:14 -0700 (PDT)
Message-ID: <20100413.025914.150962519.davem@davemloft.net>
References: <20100409195306.30654.19260.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49671
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752412Ab0DMJ7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 05:59:10 -0400
In-Reply-To: <20100409195306.30654.19260.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 09 Apr 2010 12:53:08 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> The registers for RDLEN/TDLEN on i350 have the first 7 bits as read only.
> This is a change from previous hardware in which it was only the first 4
> bits that were read only.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
