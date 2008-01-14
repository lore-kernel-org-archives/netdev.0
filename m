From: David Miller <davem@davemloft.net>
Subject: Re: [AX25]: sparse cleanups
Date: Sun, 13 Jan 2008 22:29:59 -0800 (PST)
Message-ID: <20080113.222959.82928660.davem@davemloft.net>
References: <4789EF88.9090303@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49600
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751443AbYANG37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 01:29:59 -0500
In-Reply-To: <4789EF88.9090303@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sun, 13 Jan 2008 12:01:28 +0100

> net/ax25/ax25_route.c:251:13: warning: context imbalance in 
> 'ax25_rt_seq_start' - wrong count at exit
> net/ax25/ax25_route.c:276:13: warning: context imbalance in 'ax25_rt_seq_stop' 
> - unexpected unlock
> net/ax25/ax25_std_timer.c:65:25: warning: expensive signed divide
> net/ax25/ax25_uid.c:46:1: warning: symbol 'ax25_uid_list' was not declared. 
> Should it be static?
> net/ax25/ax25_uid.c:146:13: warning: context imbalance in 'ax25_uid_seq_start' 
> - wrong count at exit
> net/ax25/ax25_uid.c:169:13: warning: context imbalance in 'ax25_uid_seq_stop' 
> - unexpected unlock
> net/ax25/af_ax25.c:573:28: warning: expensive signed divide
> net/ax25/af_ax25.c:1865:13: warning: context imbalance in 'ax25_info_start' - 
> wrong count at exit
> net/ax25/af_ax25.c:1888:13: warning: context imbalance in 'ax25_info_stop' - 
> unexpected unlock
> net/ax25/ax25_ds_timer.c:133:25: warning: expensive signed divide
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks.
