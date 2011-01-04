From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [net-next-2.6 08/08] r8169: more 8168dp support.
Date: Wed, 5 Jan 2011 00:53:35 +0100
Message-ID: <20110104235335.GA6161@electric-eye.fr.zoreil.com>
References: <20110102233751.GI5780@electric-eye.fr.zoreil.com> <C4B63551EF6C4B57BB20D6922F78AA12@realtek.com.tw> <20110104002606.GA5934@electric-eye.fr.zoreil.com> <FFFEF1293F9B4E3B81D3777F91F21B01@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	"'Ben Hutchings'" <benh@debian.org>
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:34817 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075Ab1ADXxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 18:53:52 -0500
Content-Disposition: inline
In-Reply-To: <FFFEF1293F9B4E3B81D3777F91F21B01@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hayeswang <hayeswang@realtek.com> :
[...]
> When doing reset, the nic has to notify the embedded system and wait a response.
> However, maybe the system accesses the same register at the same time, so the
> embedded system and the driver implement the same method of software mutex to
> prevent this situation.

Thanks for the information.

I have found no 8168dp in my collection. A volunteer to test this patch with
the relevant hardware would be welcome.

-- 
Ueimor
