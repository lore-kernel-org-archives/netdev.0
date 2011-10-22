From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Kernel driver r8169 not working for Realtek 8111E onboard network card
Date: Sat, 22 Oct 2011 23:44:43 +0200
Message-ID: <20111022214443.GA21689@electric-eye.fr.zoreil.com>
References: <1319296941.68390.YahooMailNeo@web161905.mail.bf1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Adrian George Sav <adi_sav@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:58514 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752071Ab1JVVr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2011 17:47:59 -0400
Content-Disposition: inline
In-Reply-To: <1319296941.68390.YahooMailNeo@web161905.mail.bf1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian George Sav <adi_sav@yahoo.com> :
[...]
> I am having trouble with the r8169 kernel driver for Realtek 8111E network
> card. The NIC works intermittently and horribly with this driver. Unusable.
> 
> Below is my config. I am happy to provide any and every other necessary
> information to help in solving this.

Up to 2.6.39 ?

Your r8169 driver is too old. Please try current -rc and send your dmesg
including the XID line from the r8169 driver.

-- 
Ueimor
