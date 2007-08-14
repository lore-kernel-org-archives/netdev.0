From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek r8168 slow outbound transfer - potential fix/workaround
Date: Tue, 14 Aug 2007 23:19:54 +0200
Message-ID: <20070814211954.GA3552@electric-eye.fr.zoreil.com>
References: <46C0A88E.7050802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Bruce Cole <bacole@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40134 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750926AbXHNVUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 17:20:55 -0400
Content-Disposition: inline
In-Reply-To: <46C0A88E.7050802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bruce Cole <bacole@gmail.com> :
[...]
> What's the status of this fix?  It (or something more refined) seems 
> necessary to correct the current performance problems with this driver.

An explanation or something more refined would be welcome.

[...]
> I can troubleshoot in more detail if that would help get a proper fix
> developed.

Can you try 2.6.23-rc3 with NAPI enabled and send a complete dmesg +
/proc/interrupts + ethtool -S output ?

-- 
Ueimor
