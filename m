From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH net-next 1/4] bnx2x: LSO code was broken on BE
 platforms
Date: Sun, 12 Dec 2010 15:54:19 +0200
Message-ID: <1292162059.20811.142.camel@lb-tlvb-vladz>
References: <1291808589.30114.65.camel@lb-tlvb-vladz>
 <1292127293.3136.261.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Dave Miller" <davem@davemloft.net>,
	"netdev list" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Ben Hutchings" <benh@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4342 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751370Ab0LLNye (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Dec 2010 08:54:34 -0500
In-Reply-To: <1292127293.3136.261.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> This fix looks like it should go into the stable/longterm series.  Since
> this driver has changed a lot since 2.6.32, you would need to provide a
> backported patch for that.

Ben, u r right. I'm preparing a similar patch series for net-2.6 at the
moment. Since the broken code was 57712 only, the only "stable" version
affected is a current net-2.6.

thanks,
vlad


