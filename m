From: David Miller <davem@davemloft.net>
Subject: Re: [1/4][BNX2]: Support NVRAM on 5709.
Date: Mon, 16 Jul 2007 18:26:31 -0700 (PDT)
Message-ID: <20070716.182631.110014484.davem@davemloft.net>
References: <1184616424.17688.18.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60546
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751262AbXGQB02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 21:26:28 -0400
In-Reply-To: <1184616424.17688.18.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 16 Jul 2007 13:07:04 -0700

> [BNX2]: Support NVRAM on 5709.
> 
> The NVRAM interface is slightly modified on the 5709.  To properly
> support it, we need to change the buffered flag in the flash data
> structure into multiple flags to indicate buffered operation, address
> translation, and the use of write enable (WREN).  The 5709 flash
> only requires the buffered operation bit to be set.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
