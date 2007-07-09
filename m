From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/8] Make some network-related proc files use
 seq_list_xxx helpers
Date: Mon, 09 Jul 2007 13:15:23 -0700 (PDT)
Message-ID: <20070709.131523.93383253.davem@davemloft.net>
References: <200707091851.l69IpAma001726@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xemul@sw.ru, xemul@openvz.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46042
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752739AbXGIUPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 16:15:01 -0400
In-Reply-To: <200707091851.l69IpAma001726@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Mon, 09 Jul 2007 11:51:10 -0700

> From: Pavel Emelianov <xemul@sw.ru>
> 
> This includes /proc/net/protocols, /proc/net/rxrpc_calls and
> /proc/net/rxrpc_connections files.
> 
> All three need seq_list_start_head to show some header.
> 
> Signed-off-by: Pavel Emelianov <xemul@openvz.org>
> Acked-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied, thanks.
