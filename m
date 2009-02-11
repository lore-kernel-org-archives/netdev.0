From: David Miller <davem@davemloft.net>
Subject: Re: [patch] pkt_sched: type should be __u32 in header
Date: Tue, 10 Feb 2009 17:18:27 -0800 (PST)
Message-ID: <20090210.171827.142378343.davem@davemloft.net>
References: <20090210152623.79149e13@dhcp-100-2-144.bos.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: cebbert@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55118
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753495AbZBKBSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 20:18:33 -0500
In-Reply-To: <20090210152623.79149e13@dhcp-100-2-144.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chuck Ebbert <cebbert@redhat.com>
Date: Tue, 10 Feb 2009 15:26:23 -0500

> Using u32 in this header breaks the build of iptables.
> 
> Signed-off-by: Chuck Ebbert <cebbert@redhat.com>

Applied, thanks Chuck.
