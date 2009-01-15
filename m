From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/34]bnx2x: Endianness issues
Date: Wed, 14 Jan 2009 21:27:48 -0800 (PST)
Message-ID: <20090114.212748.30228678.davem@davemloft.net>
References: <1231951395.11301.132.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48234
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751697AbZAOF1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:27:47 -0500
In-Reply-To: <1231951395.11301.132.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 14 Jan 2009 18:43:15 +0200

> Adding missing le_to_cpu and disabling wrong HW endianity flag (the
> two complete each other)
>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
