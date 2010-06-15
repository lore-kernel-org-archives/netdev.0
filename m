From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] cnic: Return error code in
 cnic_cm_close() if unsuccessful.
Date: Tue, 15 Jun 2010 14:24:23 -0700 (PDT)
Message-ID: <20100615.142423.200362606.davem@davemloft.net>
References: <1276628223-27125-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55329
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932485Ab0FOVYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 17:24:11 -0400
In-Reply-To: <1276628223-27125-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 15 Jun 2010 11:57:00 -0700

> So that bnx2i can handle the error condition immediately and not have to
> wait for timeout.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com.
> Signed-off-by: Eddie Wai <waie@broadcom.com>

Applied.
