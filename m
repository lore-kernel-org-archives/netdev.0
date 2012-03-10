From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 1/2] r8169: enable transmit time stamping.
Date: Sat, 10 Mar 2012 23:21:47 +0100
Message-ID: <20120310222147.GA10071@electric-eye.fr.zoreil.com>
References: <cover.1331400160.git.richardcochran@gmail.com> <7ef0f3118d1ff0925852b31397e3bb9684e5a9fd.1331400160.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41124 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752733Ab2CJWXB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Mar 2012 17:23:01 -0500
Content-Disposition: inline
In-Reply-To: <7ef0f3118d1ff0925852b31397e3bb9684e5a9fd.1331400160.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Richard Cochran <richardcochran@gmail.com> :
> This patch has been tested on a machine with the Realtek
> RTL8101E/RTL8102E PCI Express Fast Ethernet controller (rev 05).
> 
> Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
> Cc: Francois Romieu <romieu@fr.zoreil.com>

It seems ok. It is hooked at the right place.

-- 
Ueimor
