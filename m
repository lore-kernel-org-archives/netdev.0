From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: sis190 build breakage
Date: Tue, 29 Jan 2008 23:03:10 +0100
Message-ID: <20080129220310.GC15445@electric-eye.fr.zoreil.com>
References: <20080129215023.GA24152@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: maximilian attems <max@stro.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37389 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753190AbYA2WT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 17:19:59 -0500
Content-Disposition: inline
In-Reply-To: <20080129215023.GA24152@stro.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

maximilian attems <max@stro.at> :
>   CC [M]  drivers/net/sis190.o
>   drivers/net/sis190.c:329: error: sis190_pci_tbl causes a section type conflict
>   make[5]: *** [drivers/net/sis190.o] Error 1
> 
> gcc --version
> gcc (GCC) 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)

Are you building latest git with DEBUG_SECTION_MISMATCH enabled by any
misfortune ?

-- 
Ueimor
