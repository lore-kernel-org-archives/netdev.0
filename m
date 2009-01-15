From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/34]bnx2x: Protecting the link change indication
Date: Wed, 14 Jan 2009 21:26:09 -0800 (PST)
Message-ID: <20090114.212609.163711722.davem@davemloft.net>
References: <1231951385.11301.129.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48227
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751382AbZAOF0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:26:08 -0500
In-Reply-To: <1231951385.11301.129.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 14 Jan 2009 18:43:05 +0200

> Without this lock, in some race conditions the driver missed link change
> indication
> 
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
