From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net] r8169: check ALDPS bit and disable it if enabled forthe 8168g
Date: Thu, 28 Nov 2013 11:37:18 +0800
Message-ID: <D31E46711FBE4251B4BD3A75D74DB33D@realtek.com.tw>
References: <1385538516-32104-1-git-send-email-dchang@suse.com> <20131128000207.GC5342@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"'David S. Miller'" <davem@davemloft.net>, <jlee@suse.com>,
	'David Chang' <dchang@suse.com>,
	'nic_swsd' <nic_swsd@realtek.com>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:60859 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754154Ab3K1Dhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 22:37:35 -0500
In-Reply-To: <20131128000207.GC5342@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Thursday, November 28, 2013 8:02 AM
> To: Hayeswang
> Cc: netdev@vger.kernel.org; David S. Miller; jlee@suse.com; 
> David Chang
> Subject: Re: [PATCH net] r8169: check ALDPS bit and disable 
> it if enabled forthe 8168g
[...]
> Hayes, could it be that a different chipset also needs the same kind
> of fix ?

I have to check it with our hw engineers. However, I think the possible
answer is yes.
 
Best Regards,
Hayes
