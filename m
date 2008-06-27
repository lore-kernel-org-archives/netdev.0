From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [BUG or cosmic ray] WARNING: at net/sched/sch_generic.c:222
	dev_watchdog+0xe8/0x100()
Date: Fri, 27 Jun 2008 21:53:39 +0200
Message-ID: <20080627195339.GB5064@electric-eye.fr.zoreil.com>
References: <E6FF208A16840D4EBAA31D261B15A506011CAF8B@ausx3mpc121.aus.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Mario_Limonciello@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:34950 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758154AbYF0Txq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 15:53:46 -0400
Content-Disposition: inline
In-Reply-To: <E6FF208A16840D4EBAA31D261B15A506011CAF8B@ausx3mpc121.aus.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mario_Limonciello@Dell.com <Mario_Limonciello@Dell.com> :
[...]
> These all give the same behavior.

And none of the different access mode of lspci is able to access the
device once it goes to wonderland, right ?

> I'm a bit doubtful that it is not r8169 specific as I've not been
> able to ever produce this problem with other network drivers.

Does Realtek's driver exhibit the same behavior with 2.6.26 ?

-- 
Ueimor
