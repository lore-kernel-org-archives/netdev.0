From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 6/7] ixgbe: dcb, do not tag tc_prio_control
 frames
Date: Tue, 18 May 2010 19:44:59 -0700 (PDT)
Message-ID: <20100518.194459.219733506.davem@davemloft.net>
References: <20100519020003.18654.94899.stgit@localhost.localdomain>
	<20100519020011.18654.3836.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	john.r.fastabend@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46552
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754969Ab0ESCou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 22:44:50 -0400
In-Reply-To: <20100519020011.18654.3836.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 18 May 2010 19:00:11 -0700

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> The network stack indicate packets should not be DCB
> tagged by setting the priority to TC_PRIO_CONTROL. One
> usage for this is lldp frames which are not suppossed
> to be tagged.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
