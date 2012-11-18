From: David Miller <davem@davemloft.net>
Subject: Re: [net-next patch] vxlan: remove unused variable.
Date: Sat, 17 Nov 2012 22:02:44 -0500 (EST)
Message-ID: <20121117.220244.1281406637766032484.davem@davemloft.net>
References: <1353161287-22493-1-git-send-email-ramirose@gmail.com>
	<20121117095225.48bd9ab1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ramirose@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44380 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752365Ab2KRDCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2012 22:02:45 -0500
In-Reply-To: <20121117095225.48bd9ab1@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sat, 17 Nov 2012 09:52:25 -0800

> On Sat, 17 Nov 2012 16:08:07 +0200
> Rami Rosen <ramirose@gmail.com> wrote:
> 
>> This patch removes addrexceeded member from vxlan_dev struct as it is unused.
>> 
>> Signed-off-by: Rami Rosen <ramirose@gmail.com>
 ...
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
