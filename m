From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [stable] [PATCH NET-2.6 1/1] qlcnic: limit skb frags for non
 tso packet
Date: Wed, 13 Apr 2011 00:56:56 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80FD1383FDF@MNEXMB2.qlogic.org>
References: <1302592781-13881-1-git-send-email-amit.salecha@qlogic.com>
 <1302592781-13881-2-git-send-email-amit.salecha@qlogic.com>
 <20110412.135522.71113479.davem@davemloft.net>
 <99737F4847ED0A48AECC9F4A1974A4B80FD1383FAC@MNEXMB2.qlogic.org>
 <20110413034228.GA852@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	"stable@kernel.org" <stable@kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe004.messaging.microsoft.com ([216.32.181.184]:23714
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757052Ab1DMF5D convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 01:57:03 -0400
In-Reply-To: <20110413034228.GA852@kroah.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Tue, Apr 12, 2011 at 09:01:13PM -0500, Amit Salecha wrote:
> >
> > This message and any attached documents contain information from
> QLogic Corporation or its wholly-owned subsidiaries that may be
> confidential. If you are not the intended recipient, you may not read,
> copy, distribute, or use this information. If you have received this
> transmission in error, please notify the sender immediately by reply e-
> mail and then delete this message.
>
> I have received this transmission in error.
>
> Please remove this from your footer, otherwise we can not accept any
> emails sent from you as actually being allowed to contribute to the
> kernel properly :(
>
I have send version two of this patch, that doesn't have this footer.
Please discard this one.

This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.

