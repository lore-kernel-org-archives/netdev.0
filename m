From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] bnx2x: Fixed a compilation warning
Date: Thu, 09 Dec 2010 20:50:29 -0800 (PST)
Message-ID: <20101209.205029.48506537.davem@davemloft.net>
References: <1291808609.30114.67.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46500
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756040Ab0LJEuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 23:50:01 -0500
In-Reply-To: <1291808609.30114.67.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Wed, 8 Dec 2010 13:43:29 +0200

> bnx2x_src_init_t2() is used only when BCM_CNIC is defined.
> So, to avoid a compilation warning, we won't define it unless
> BCM_CNIC is defined.
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
