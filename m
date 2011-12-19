From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2: Update driver to use new mips firmware.
Date: Mon, 19 Dec 2011 15:48:04 -0500 (EST)
Message-ID: <20111219.154804.255413353396711289.davem@davemloft.net>
References: <1324268109-27740-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430Ab1LSUsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 15:48:08 -0500
In-Reply-To: <1324268109-27740-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Sun, 18 Dec 2011 20:15:09 -0800

> bnx2-mips-06-6.2.3 and bnx2-mips-09-6.2.1.b
> 
> New firmware fixes iSCSI problems with some LeftHand targets that don't
> set TTT=0xffffffff for Data-In according to spec.  Firmware generates
> exception warnings for this condition and becomes very slow.  This is
> fixed by suppressing these warnings when using default error mask.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
