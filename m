From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/34]bnx2x: Using system page size for SGE
Date: Wed, 14 Jan 2009 21:24:32 -0800 (PST)
Message-ID: <20090114.212432.118773987.davem@davemloft.net>
References: <1231951371.11301.125.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48218
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750735AbZAOFYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:24:31 -0500
In-Reply-To: <1231951371.11301.125.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 14 Jan 2009 18:42:51 +0200

> When the page size is not 4KB, the FW must be programmed to work
> with the right SGE boundaries and fragment list length.
>
> To avoid confusion with the BCM_PAGE_SIZE which is set to 4KB for
> the FW sake, another alias for the system page size was added to
> explicitly indicate that it is meant for the SGE
>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
