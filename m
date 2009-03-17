From: David Miller <davem@davemloft.net>
Subject: Re: [patch next] netxen: fix firmware download warnings
Date: Tue, 17 Mar 2009 13:14:31 -0700 (PDT)
Message-ID: <20090317.131431.47471677.davem@davemloft.net>
References: <1237185662-16726-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfr@canb.auug.org.au
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35628
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754619AbZCQUOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 16:14:44 -0400
In-Reply-To: <1237185662-16726-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Sun, 15 Mar 2009 23:41:02 -0700

> Fix following warnings, by using integer firmware types.
> 
> drivers/net/netxen/netxen_nic_hw.c: In function 'netxen_load_firmware':
> drivers/net/netxen/netxen_nic_hw.c:1146: warning: comparison with string literal results in unspecified behavior
> drivers/net/netxen/netxen_nic_hw.c:1146: warning: comparison with string literal results in unspecified behavior
> drivers/net/netxen/netxen_nic_hw.c:1146: warning: comparison with string literal results in unspecified behavior
> drivers/net/netxen/netxen_nic_hw.c:1159: warning: comparison with string literal results in unspecified behavior
> drivers/net/netxen/netxen_nic_hw.c:1159: warning: comparison with string literal results in unspecified behavior
> drivers/net/netxen/netxen_nic_hw.c:1159: warning: comparison with string literal results in unspecified behavior
> 
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied, thanks.
