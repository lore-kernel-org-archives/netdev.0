From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: various fixes for bonding, netpoll &
 netconsole (v3)
Date: Tue, 19 Oct 2010 01:06:42 -0700 (PDT)
Message-ID: <20101019.010642.193703612.davem@davemloft.net>
References: <1287021713-1750-1-git-send-email-nhorman@tuxdriver.com>
	<20101018.082529.115920035.davem@davemloft.net>
	<4CBD2AE7.9010302@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, fubar@us.ibm.com,
	andy@greyhouse.net
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36004
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933847Ab0JSIGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 04:06:20 -0400
In-Reply-To: <4CBD2AE7.9010302@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue, 19 Oct 2010 13:21:43 +0800

> Which tree do you apply this patchset to? I checked both net-2.6
> and net-next-2.6, neither of them has these patches.

net-next-2.6, but I didn't push it out until just now so that
I could do build testing first...
