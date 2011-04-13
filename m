From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCHv4 NEXT 1/1] net: ethtool support to configure number of
 channels
Date: Wed, 13 Apr 2011 04:45:11 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80FD1384031@MNEXMB2.qlogic.org>
References: <1302177522-17815-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1outboundpool.messaging.microsoft.com ([216.32.181.182]:38730
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754573Ab1DMJqZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 05:46:25 -0400
In-Reply-To: <1302177522-17815-1-git-send-email-amit.salecha@qlogic.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Ethtool support to configure RX, TX and other channels. combined field
> in struct ethtool_channels to reflect set of channel (RX, TX or other).
> Other channel can be link interrupts, SR-IOV coordination etc.
>
> ETHTOOL_GCHANNELS will report max and current number of RX channels,
> max and current number of TX channels, max and current number of other
> channel
> or max and current number of combined channel.
>
> Number of channel can be modify upto max number of channel through
> ETHTOOL_SCHANNELS command.
>
> Ben Hutchings:
> o define 'combined' and 'other' types.  Most multiqueue drivers pair up
> RX and TX
>   queues so that most channels combine RX and TX work.
> o Please could you use a kernel-doc comment to describe the structure.
>
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Neither I see this patch in http://patchwork.ozlabs.org/project/netdev/list/ nor any comment.
Just curious, is this patch discarded along with my other garbage patches ?

-Amit


This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.

