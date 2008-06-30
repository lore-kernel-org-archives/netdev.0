From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/2] r8169: multicast register update (sync with
	Realtek's 8.004.00 8168 driver)
Date: Mon, 30 Jun 2008 23:17:32 +0200
Message-ID: <20080630211732.GA24253@electric-eye.fr.zoreil.com>
References: <20080629131739.GA31201@electric-eye.fr.zoreil.com> <20080629131852.GB31201@electric-eye.fr.zoreil.com> <5B0BE23C-3952-40DB-94B5-453417DA21D4@lincor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: Glen Gray <glen.gray@lincor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38666 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753617AbYF3VRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 17:17:54 -0400
Content-Disposition: inline
In-Reply-To: <5B0BE23C-3952-40DB-94B5-453417DA21D4@lincor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Glen Gray <glen.gray@lincor.com> :
[...]
> Do you think this might resolve my issues with multicast SAP announcements 
> ?

I do not think so. The change is only relevant for the 8168.

-- 
Ueimor
