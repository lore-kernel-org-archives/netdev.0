From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] forgotten bits of Sangoma drivers removal
Date: Mon, 31 Mar 2008 19:33:29 -0700 (PDT)
Message-ID: <20080331.193329.195976331.davem@davemloft.net>
References: <20080330224901.GW28445@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rpjday@crashcourse.ca
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53215
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752730AbYDACd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 22:33:29 -0400
In-Reply-To: <20080330224901.GW28445@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>
Date: Mon, 31 Mar 2008 01:49:01 +0300

> Robert P. J. Day spotted that my removal of the Sangoma drivers missed a 
> few bits.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

I must have missed some context or another patch, but
linux/if_wanpipe.h is still there, so I can't see why
we can remove it from linux/Kbuild
