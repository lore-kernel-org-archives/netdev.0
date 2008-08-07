From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek 8111C transmit timed out
Date: Fri, 8 Aug 2008 00:31:37 +0200
Message-ID: <20080807223137.GA17407@electric-eye.fr.zoreil.com>
References: <2c2a4e250808041812j569f6565s9f4ae54f44bbfbb5@mail.gmail.com> <2c2a4e250808041900id64a2b8h1b7cee3b70960ebc@mail.gmail.com> <2c2a4e250808042042j6c448068v98a6b5e428fa1a7@mail.gmail.com> <20080805214250.GA23226@electric-eye.fr.zoreil.com> <2c2a4e250808052221p7d22adf5w7a656e423bff0b26@mail.gmail.com> <20080806190353.GB17174@electric-eye.fr.zoreil.com> <2c2a4e250808062251p74f97863l770727843921a5c4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: John P Poet <jppoet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:42722 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753664AbYHGWbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 18:31:41 -0400
Content-Disposition: inline
In-Reply-To: <2c2a4e250808062251p74f97863l770727843921a5c4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John P Poet <jppoet@gmail.com> :
[...]
> That does not make any difference.
> 
> I will say, that the problem seems to be reduced by this patch (or the
> 0002-r8169-avoid-thrashing-PCI-conf-space-above-RTL_GIGA.patch).
> 
> Before, I was getting failures two or three times an hour.  With
> either of these patches applied, the failure rate has dropped to one
> every two to four hours.

I have updated the kit at http://userweb.kernel.org/~romieu/r8169/2.6.27-rc2

Can you give it a try ?

-- 
Ueimor
