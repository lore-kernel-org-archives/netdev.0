From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Adding licensing to bnx2x_init_values.h
Date: Sun, 22 Mar 2009 21:26:11 -0700 (PDT)
Message-ID: <20090322.212611.194911779.davem@davemloft.net>
References: <1237720494.10353.1.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38639
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750758AbZCWE0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 00:26:23 -0400
In-Reply-To: <1237720494.10353.1.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Sun, 22 Mar 2009 13:14:54 +0200

> Subject: [PATCH net-next] Adding licensing to bnx2x_init_values.h
> 
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks.

Please format your subject lines something like:

Subject: [PATCH/RFC/WHATEVER] bnx2x: Description....

This allows the automated GIT tools to compose a suitable commit
header line.  Everthing inside of the initial "[]" brackets will be
removed and the remaining line text will be the commit message header
line.

Adding a second subject line into the message body as well is also
superfluous and confusing, please eliminate it.

Thanks.
