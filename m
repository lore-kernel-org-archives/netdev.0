From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 25/34]bnx2x: Wrong HDR offset in CAM
Date: Sat, 17 Jan 2009 23:22:39 -0800 (PST)
Message-ID: <20090117.232239.75994996.davem@davemloft.net>
References: <1231951439.11301.146.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47540
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755940AbZARHWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 02:22:37 -0500
In-Reply-To: <1231951439.11301.146.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 14 Jan 2009 18:43:59 +0200

> Has a negative side effect when sending MAC update with no content (as done in
> the self-test)
> 
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
