From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netdev: missing validate_address hooks
Date: Fri, 09 Jan 2009 23:11:11 -0800 (PST)
Message-ID: <20090109.231111.148455893.davem@davemloft.net>
References: <20090109124427.71d15306@s6510>
	<20090109124537.346c61d8@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56688
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754028AbZAJHLL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 02:11:11 -0500
In-Reply-To: <20090109124537.346c61d8@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 9 Jan 2009 12:45:37 -0800

> Some devices were converted incorrectly and are missing the validate
> address hooks.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
