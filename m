From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: linux-next: Tree for Dec 22 (netdev/stmmac)
Date: Fri, 23 Dec 2011 11:18:49 +0100
Message-ID: <4EF45589.2080709@st.com>
References: <20111222172039.dc704e5bbfc3d91a844897b3@canb.auug.org.au> <4EF3DB45.30401@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:53309 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751481Ab1LWKTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 05:19:11 -0500
In-Reply-To: <4EF3DB45.30401@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/23/2011 2:37 AM, Randy Dunlap wrote:
> On 12/21/2011 10:20 PM, Stephen Rothwell wrote:
>> Hi all,
>>
>> This will probably be the last linux-next tree until the new year (unless
>> I get exceedingly bored :-)).
> 
> goody :)
> 
> 
> WARNING: modpost: missing MODULE_LICENSE() in drivers/net/ethernet/stmicro/stmmac/stmmac.o
> see include/linux/module.h for more information
> 

I'm fixing that and send you a patch

Peppe
