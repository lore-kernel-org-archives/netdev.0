From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/6] bnx2: Add ack parameter to bnx2_fw_sync().
Date: Mon, 14 Jul 2008 22:38:32 -0700 (PDT)
Message-ID: <20080714.223832.192340133.davem@davemloft.net>
References: <1215739755-5495-1-git-send-email-mchan@broadcom.com>
	<1215739755-5495-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46161
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756744AbYGOFib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 01:38:31 -0400
In-Reply-To: <1215739755-5495-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 10 Jul 2008 18:29:12 -0700

> ack=1 means wait for firmware acknowledgement, and ack=0
> means don't wait.  All current callers will set it to 1.
> 
> In the next patch, new calls will set ack=0.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
