From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/10] ieee802154: support rf212 and
 extended mac features
Date: Mon, 17 Feb 2014 16:45:47 -0500 (EST)
Message-ID: <20140217.164547.104924757912644737.davem@davemloft.net>
References: <1392633255-26605-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: phoebe.buckheister@itwm.fraunhofer.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51549 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752270AbaBQVpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 16:45:49 -0500
In-Reply-To: <1392633255-26605-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Date: Mon, 17 Feb 2014 11:34:05 +0100

> this patch set adds support for the RF212 radio chip to the existing
> at86rf230 driver and adds support for numerous features of the RF212
> chips to the ieee802154 stack. These features include CSMA parameter
> configuration, transmit power control, CCA parameter configuration, and
> automatic retransmission of frames. Netlink APIs are provided for all
> new options introduced in this set.
> 
> Many features might also work for RF230, but since I have no such chips
> at my disposal, most new features are implemented only for RF212.
> 
> Changes since v2:
>  * Indentation
> Changes since v1:
>  * CodingStyle compliance. Thanks Sergei Shtylyov
>  * Add CSMA parameters to netlink phy list that were forgotten in v1

Series applied, thanks.
