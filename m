From: maximilian attems <max@stro.at>
Subject: Re: [PATCH 6/7][BNX2]: Update firmware.
Date: Wed, 30 Jan 2008 00:46:15 +0100
Message-ID: <20080129234615.GB25253@stro.at>
References: <1201652420.19087.15.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:40105 "EHLO
	baikonur.stro.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759491AbYA2XqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 18:46:21 -0500
Content-Disposition: inline
In-Reply-To: <1201652420.19087.15.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Jan 2008, Michael Chan wrote:

> [BNX2]: Update firmware.
> 
> Update firmware to support programmable flow control.
>  
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> diff --git a/drivers/net/bnx2_fw.h b/drivers/net/bnx2_fw.h
> index c1ad4dd..3b839d4 100644

happily omitted diffstat:
 drivers/net/bnx2_fw.h  | 1499 +++++++++++++++++++--------------------
 drivers/net/bnx2_fw2.h |  464 ++++++------
 2 files changed, 982 insertions(+), 981 deletions(-)


when can bnx2 grow up to proper request_firmware() usage?
