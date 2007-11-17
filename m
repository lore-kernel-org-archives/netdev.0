From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 crash
Date: Sat, 17 Nov 2007 23:07:59 +0100
Message-ID: <20071117220759.GA2862@electric-eye.fr.zoreil.com>
References: <20071117053920.M40084@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58181 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750701AbXKQWJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2007 17:09:59 -0500
Content-Disposition: inline
In-Reply-To: <20071117053920.M40084@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys <nuclearcat@nuclearcat.com> :
[...]
> After that i have.
> Nov 15 22:11:37 vzone NETDEV WATCHDOG: eth1: transmit timed out
> Nov 15 22:11:49 vzone NETDEV WATCHDOG: eth1: transmit timed out
> Nov 15 22:12:01 vzone NETDEV WATCHDOG: eth1: transmit timed out
> Nov 15 22:12:13 vzone NETDEV WATCHDOG: eth1: transmit timed out
> Nov 15 22:12:25 vzone NETDEV WATCHDOG: eth1: transmit timed out
> Nov 15 22:12:37 vzone NETDEV WATCHDOG: eth1: transmit timed out
> Nov 15 22:12:49 vzone NETDEV WATCHDOG: eth1: transmit timed out
> Nov 15 22:13:01 vzone NETDEV WATCHDOG: eth1: transmit timed out

Is there a chance for you to verify that the network interface does
not recover if a real cable is plugged at this point ?

-- 
Ueimor
