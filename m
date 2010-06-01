From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: convert hdr.timeout in be_cmd_loopback_test()
 to le32
Date: Tue, 01 Jun 2010 00:19:41 -0700 (PDT)
Message-ID: <20100601.001941.220043828.davem@davemloft.net>
References: <20100601070122.GA2608@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42469
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753411Ab0FAHTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 03:19:31 -0400
In-Reply-To: <20100601070122.GA2608@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Tue, 1 Jun 2010 12:31:22 +0530

> The current code fails on ppc as hdr.timeout is not being converted
> to le32.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
