From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next] Sweep away N/A fw_version dustbunnies from the .get_drvinfo routine of a number of drivers
Date: Tue, 22 Nov 2011 23:22:35 +0100
Message-ID: <20111122222235.GA24136@electric-eye.fr.zoreil.com>
References: <20111121205405.A0FF1290041F@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Rick Jones <raj@tardy.cup.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:47890 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753536Ab1KVW3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 17:29:11 -0500
Content-Disposition: inline
In-Reply-To: <20111121205405.A0FF1290041F@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones <raj@tardy.cup.hp.com> :
[...]
> Per discussion with Ben Hutchings and David Miller, go through and
> remove assignments of "N/A" to fw_version in various drivers'
> .get_drvinfo routines.  While there clean-up some use of bare
> constants and such.

Any reason why drivers/net/ethernet/realtek/r8169.c is left in the
cold ?

-- 
Ueimor
