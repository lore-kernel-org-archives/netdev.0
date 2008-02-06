From: David Miller <davem@davemloft.net>
Subject: Re: [VLAN 03/04]: Constify skb argument to vlan_get_tag()
Date: Tue, 05 Feb 2008 16:20:29 -0800 (PST)
Message-ID: <20080205.162029.16689052.davem@davemloft.net>
References: <20080205142902.13543.88604.sendpatchset@localhost.localdomain>
	<20080205142906.13543.98167.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59552
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760546AbYBFAUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 19:20:00 -0500
In-Reply-To: <20080205142906.13543.98167.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue,  5 Feb 2008 15:29:43 +0100 (MET)

> [VLAN]: Constify skb argument to vlan_get_tag()
> 
> Required by next patch to use it from the flow classifier.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
