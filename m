From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 2/3] netxen: remove unnecessary structures
Date: Wed, 05 Aug 2009 12:41:18 -0700 (PDT)
Message-ID: <20090805.124118.09692255.davem@davemloft.net>
References: <1249493649-26336-1-git-send-email-dhananjay@netxen.com>
	<1249493649-26336-2-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.com, netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39664
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752011AbZHETlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 15:41:09 -0400
In-Reply-To: <1249493649-26336-2-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Wed,  5 Aug 2009 10:34:08 -0700

> Remove unnecessary offsetof calulations on these structures:
> netxen_board_info, netxen_user_old_info, netxen_new_user_info.
> 
> The offsets into the flash are fixed, don't need to be calculated.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
