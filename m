From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/19] bnx2x, cnic, bnx2i: Supporting 57712
 device
Date: Wed, 06 Oct 2010 14:11:00 -0700 (PDT)
Message-ID: <20101006.141100.48490833.davem@davemloft.net>
References: <1286370813.30552.7.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, mchan@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46810
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756530Ab0JFVKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 17:10:39 -0400
In-Reply-To: <1286370813.30552.7.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Wed, 6 Oct 2010 15:13:33 +0200

> 01 cnic: Pass cp pointer to BNX2X_HW_CID.
> 02 cnic: Use pfid for internal memory offsets.
> 03 cnic: Fine-tune ring init code.
> 04 bnx2x: create folder for bnx2x firmware files
> 05 bnx2x: add 6.0.34 fw files
> 06 bnx2x, cnic, bnx2i: use new FW/HSI
> 07 bnx2x: remove old FW files 
> 08 bnx2x: rename MF related fields
> 09 bnx2x: change type of spq_left to atomic
> 10 bnx2x: Add 57712 support
> 11 bnx2x: remove unused parameter in reuse_rx_skb()
> 12 bnx2x: remove unused fields in main driver structure
> 13 bnx2x: use proper constants for dma_unmap* calls
> 14 bnx2x: use L1_CACHE_BYTES instead of magic number
> 15 bnx2x: move msix table initialization to probe()
> 16 bnx2x, cnic: Fix SPQ return credit
> 17 bnx2x: code beautify
> 18 bnx2x: properly initialize FW stats
> 19 bnx2x: update version to 1.60.00-1
> 
> Please consider applying to net-next.

All applied, thanks.
