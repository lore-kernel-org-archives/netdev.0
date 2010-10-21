From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pch_gbe: make local functions static
Date: Thu, 21 Oct 2010 03:14:37 -0700 (PDT)
Message-ID: <20101021.031437.246534304.davem@davemloft.net>
References: <20101015140914.01d8ef08@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: masa-korg@dsn.okisemi.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60534
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755511Ab0JUKOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 06:14:14 -0400
In-Reply-To: <20101015140914.01d8ef08@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 15 Oct 2010 14:09:14 -0700

> Make routines that are only used in one file static.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
