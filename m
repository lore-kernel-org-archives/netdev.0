From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Load firmware in open() instead of
 probe()
Date: Tue, 17 Aug 2010 02:34:24 -0700 (PDT)
Message-ID: <20100817.023424.193686306.davem@davemloft.net>
References: <1280908180.4712.3.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34270
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932160Ab0HQJeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 05:34:07 -0400
In-Reply-To: <1280908180.4712.3.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Wed, 4 Aug 2010 10:49:40 +0300

> Loading firmware when actually bringing eth device up.
> This also will allow driver to be insmoded when filesystem with
> firmware files is not available yet.
> 
> Suggested by Stephen Hemminger <shemminger@vyatta.com>
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
