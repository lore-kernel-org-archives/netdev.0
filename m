From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 4/5] r8169: more alignment for the 0x8168
Date: Sat, 24 Feb 2007 00:13:56 +0100
Message-ID: <20070223231355.GA10930@electric-eye.fr.zoreil.com>
References: <20061203235257.GA3625@electric-eye.fr.zoreil.com> <20061204000327.GE3625@electric-eye.fr.zoreil.com> <45D13578.8040405@snapgear.com> <20070213081439.GA21261@electric-eye.fr.zoreil.com> <Pine.LNX.4.64.0702131730570.14346@cnc.isely.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Philip Craig <philipc@snapgear.com>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
To: Mike Isely <isely@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40099 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933252AbXBWXOi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Feb 2007 18:14:38 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0702131730570.14346@cnc.isely.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mike Isely <isely@isely.net> :
[...]
> Obviously I have an interest in any change here not breaking the NIC on 
> my system.  So please let me know if/when you'd like me to test drive a 
> candidate fix that keeps everyone happy...

The experimental r8169 patch of the day against 2.6.21-rc1 is available at:
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.21-rc1/

-- 
Ueimor
