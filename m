From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek 8111C transmit timed out
Date: Tue, 12 Aug 2008 22:18:47 +0200
Message-ID: <20080812201847.GA1582@electric-eye.fr.zoreil.com>
References: <2c2a4e250808041900id64a2b8h1b7cee3b70960ebc@mail.gmail.com> <2c2a4e250808042042j6c448068v98a6b5e428fa1a7@mail.gmail.com> <20080805214250.GA23226@electric-eye.fr.zoreil.com> <2c2a4e250808052221p7d22adf5w7a656e423bff0b26@mail.gmail.com> <20080806190353.GB17174@electric-eye.fr.zoreil.com> <2c2a4e250808062251p74f97863l770727843921a5c4@mail.gmail.com> <20080807223137.GA17407@electric-eye.fr.zoreil.com> <2c2a4e250808072028h8b7a13av29ec02f76ab08cd1@mail.gmail.com> <2c2a4e250808072051v6b0b42eaxb66e927e094dba78@mail.gmail.com> <ec7e30370808112242y4be0ba5fy6d3567e0dc49b6fd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John P Poet <jppoet@gmail.com>, netdev@vger.kernel.org
To: David Madsen <david.madsen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40381 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750980AbYHLUSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 16:18:51 -0400
Content-Disposition: inline
In-Reply-To: <ec7e30370808112242y4be0ba5fy6d3567e0dc49b6fd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Madsen <david.madsen@gmail.com> :
[...]
> I also have a Realtek GigE card that was quite stable running on
> 2.6.24.  I recently updated my kernel briefly to 2.6.25.10 then
> ultimately to 2.6.26.2 and started seeing similar timeouts in both
> kernel versions.

Please note that the kernel complains more loudly about the watchdog
than it used to. Does it allow traffic to flow afterwards ?

-- 
Ueimor
