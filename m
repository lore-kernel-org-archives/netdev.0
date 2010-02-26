From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: use list_first_entry macro
Date: Fri, 26 Feb 2010 04:20:06 -0800 (PST)
Message-ID: <20100226.042006.191452710.davem@davemloft.net>
References: <20100224160138.3a8de8de@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48556
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S936011Ab0BZMTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 07:19:48 -0500
In-Reply-To: <20100224160138.3a8de8de@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 24 Feb 2010 16:01:38 -0800

> Use list_first_entry macro; no longer any need to use 
> 'next' directly in list to find first entry.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
