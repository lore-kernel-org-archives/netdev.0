From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] cnic: Do not allow iSCSI and FCoE on
 bnx2x multi-function mode
Date: Mon, 03 Jan 2011 19:08:29 -0800 (PST)
Message-ID: <20110103.190829.189702736.davem@davemloft.net>
References: <1294104106-9758-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39225
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750830Ab1ADDH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 22:07:58 -0500
In-Reply-To: <1294104106-9758-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 3 Jan 2011 17:21:45 -0800

> Because the hardware does not yet support these in this mode.
> 
> Reviewed-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
