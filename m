From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Bogus frames transmitted with r8169 & fragmentation & large mtu
Date: Wed, 15 Feb 2012 23:41:22 +0100
Message-ID: <20120215224122.GA31463@electric-eye.fr.zoreil.com>
References: <20120215163748.GA3998@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Nick Bowler <nbowler@elliptictech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39431 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472Ab2BOWxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 17:53:47 -0500
Content-Disposition: inline
In-Reply-To: <20120215163748.GA3998@elliptictech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nick Bowler <nbowler@elliptictech.com> :
[...]
> Let me know if you need any more info,

Please send the XID line from the r8169 driver for this device.

Did you enable some offload feature (see 'ethtool -k') ?

-- 
Ueimor
