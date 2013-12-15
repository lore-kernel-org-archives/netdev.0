From: David Miller <davem@davemloft.net>
Subject: Re: 3.13-rc1: eth0 hw csum failure on powerpc (bisected)
Date: Sat, 14 Dec 2013 22:34:53 -0500 (EST)
Message-ID: <20131214.223453.1858856767733226007.davem@davemloft.net>
References: <alpine.DEB.2.11.1311301314220.31521__48727.6146108799$1385846242$gmane$org@trent.utfs.org>
	<87vbz9pmud.fsf@igel.home>
	<alpine.DEB.2.11.1312141622230.25690@trent.utfs.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: schwab@linux-m68k.org, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	agraf@suse.de
To: lists@nerdbynature.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1312141622230.25690@trent.utfs.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christian Kujau <lists@nerdbynature.de>
Date: Sat, 14 Dec 2013 16:40:39 -0800 (PST)

> And sure enough, today's 3.13-rc3 with only that commit reverted boots 
> just fine on this PowerBook G4 system.

It's reverted in my 'net' tree, that tree simple hasn't been pushed to
Linus just yet, please be patient.
