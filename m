From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: Fix problems with the new
 SCTP_DELAYED_ACK code
Date: Mon, 09 Jun 2008 15:45:51 -0700 (PDT)
Message-ID: <20080609.154551.202822490.davem@davemloft.net>
References: <1212807007-24379-1-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41834
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751624AbYFIWpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 18:45:51 -0400
In-Reply-To: <1212807007-24379-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri,  6 Jun 2008 22:50:07 -0400

> The default sack frequency should be 2.  Also fix copy/paste
> error when updating all transports.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied to net-next-2.6, thanks Vlad.
