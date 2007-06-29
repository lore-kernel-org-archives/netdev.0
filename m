From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PATCHES] SCTP fixes
Date: Thu, 28 Jun 2007 21:24:35 -0700 (PDT)
Message-ID: <20070628.212435.03979074.davem@davemloft.net>
References: <11830412972450-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53764
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750813AbXF2EYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 00:24:15 -0400
In-Reply-To: <11830412972450-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu, 28 Jun 2007 10:34:57 -0400

> 
> Hi David
> 
> Please pull the following changes:
> 
> The following changes since commit 19e6454ca778e11e81497bd87c930dc0defd03d7:
>   David Howells (1):
>         [AF_RXRPC]: Return the number of bytes buffered in rxrpc_send_data()
> 
> are found in the git repository at:
> 
>   master.kernel.org:/pub/scm/linux/kernel/git/vxy/lksctp-dev.git
> 
> Neil Horman (2):
>       SCTP: update sctp_getsockopt helpers to allow oversized buffers
>       SCTP: Fix sctp_getsockopt_get_peer_addrs
> 
> Zach Brown (1):
>       SCTP: lock_sock_nested in sctp_sock_migrate

Pulled, thanks a lot Vlad.
