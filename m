From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/4] cnic: Refactor code in
 cnic_cm_process_kcqe().
Date: Tue, 15 Jun 2010 14:24:31 -0700 (PDT)
Message-ID: <20100615.142431.212679830.davem@davemloft.net>
References: <1276628223-27125-1-git-send-email-mchan@broadcom.com>
	<1276628223-27125-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55333
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932481Ab0FOVYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 17:24:20 -0400
In-Reply-To: <1276628223-27125-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 15 Jun 2010 11:57:01 -0700

> Move chip-specific code to the respective chip's ->close_conn() functions
> for better code organization.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Eddie Wai <waie@broadcom.com>

Applied.
