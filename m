From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 17/34]bnx2x: First slow path interrupt race
Date: Wed, 14 Jan 2009 21:31:23 -0800 (PST)
Message-ID: <20090114.213123.147085495.davem@davemloft.net>
References: <1231951413.11301.138.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40681
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751498AbZAOFbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:31:22 -0500
In-Reply-To: <1231951413.11301.138.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 14 Jan 2009 18:43:33 +0200

> The "read for interrupts" flag must be set before enabling slow-path
> interrupts as well (and not just before fast-path interrupts)
>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
