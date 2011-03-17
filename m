From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-dev2.6] bxn2x: Fix location of PCI-ids defines
Date: Thu, 17 Mar 2011 06:06:50 -0700 (PDT)
Message-ID: <20110317.060650.226776465.davem@davemloft.net>
References: <1300364824.2090.57.camel@lb-tlvb-ariel.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: ariele@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37667
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754057Ab1CQNGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 09:06:12 -0400
In-Reply-To: <1300364824.2090.57.camel@lb-tlvb-ariel.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ariel Elior" <ariele@broadcom.com>
Date: Thu, 17 Mar 2011 14:27:04 +0200

> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Unless you intend to reference these symbols elsewhere in the
kernel, they should stay private in your driver.
