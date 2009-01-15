From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/34]bnx2x: Missing memory barriers
Date: Wed, 14 Jan 2009 21:23:47 -0800 (PST)
Message-ID: <20090114.212347.159312179.davem@davemloft.net>
References: <1231951368.11301.124.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48215
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750768AbZAOFXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:23:46 -0500
In-Reply-To: <1231951368.11301.124.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 14 Jan 2009 18:42:47 +0200

> While working on IA64, it became clear that the following memory
> barriers are missing
>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
