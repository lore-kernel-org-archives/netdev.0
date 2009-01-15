From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/34]bnx2x: VLAN tagged packets without VLAN offload
Date: Wed, 14 Jan 2009 21:27:01 -0800 (PST)
Message-ID: <20090114.212701.196718265.davem@davemloft.net>
References: <1231951389.11301.130.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48231
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751071AbZAOF07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:26:59 -0500
In-Reply-To: <1231951389.11301.130.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 14 Jan 2009 18:43:09 +0200

> Wrong handling of tagged packet if VLAN offload is disabled caused
> packets to get corrupted
>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
