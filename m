From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek 8111C transmit timed out
Date: Tue, 5 Aug 2008 23:42:50 +0200
Message-ID: <20080805214250.GA23226@electric-eye.fr.zoreil.com>
References: <2c2a4e250808041812j569f6565s9f4ae54f44bbfbb5@mail.gmail.com> <2c2a4e250808041900id64a2b8h1b7cee3b70960ebc@mail.gmail.com> <2c2a4e250808042042j6c448068v98a6b5e428fa1a7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: John P Poet <jppoet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39711 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750713AbYHEVmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 17:42:54 -0400
Content-Disposition: inline
In-Reply-To: <2c2a4e250808042042j6c448068v98a6b5e428fa1a7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(please Cc: the maintainer)

John P Poet <jppoet@gmail.com> :
[...]
> I just tried applying ALL the patches found here:
> 
> http://userweb.kernel.org/~romieu/r8169/2.6.27-rc1/20080803.tar.bz2
> 
> against 2.6.26.1.  Worked for a while, I then I got:

Try to add 0002-r8169-avoid-thrashing-PCI-conf-space-above-RTL_GIGA.patch
from http://userweb.kernel.org/~romieu/r8169/2.6.26/20080717/

It is in 2.6.27-rc1 as 77332894c21165404496c56763d7df6c15c4bb09.

-- 
Ueimor
