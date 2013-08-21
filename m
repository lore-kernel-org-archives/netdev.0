From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v3] r8169: fix invalid register dump
Date: Wed, 21 Aug 2013 22:53:25 +0200
Message-ID: <20130821205325.GA24054@electric-eye.fr.zoreil.com>
References: <1376833298-7321-1-git-send-email-lekensteyn@gmail.com>
 <20130820.150213.1489180923839317674.davem@davemloft.net>
 <18365346.kxAWDne41Q@al>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	netdev@vger.kernel.org, nic_swsd@realtek.com
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40820 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752844Ab3HUUxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 16:53:41 -0400
Content-Disposition: inline
In-Reply-To: <18365346.kxAWDne41Q@al>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Wu <lekensteyn@gmail.com> :
[...]
> Please find the updated patch below. There may be differences in lines
> because net-next has the r8169,sis190 patch and net the WOL fix.
> 
> Can I consider Francois reply[1] as Acked-by?

Yes, provided you insert an empty line between declarations and code.

You may / should send patches as normal submissions. It will probably
be easier for davem to use and you can always raise questions or add
minor remarks in the "--- ... diff" section.

-- 
Ueimor
