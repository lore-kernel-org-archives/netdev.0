From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 6/11][CORE] Remove the empty net_table
Date: Wed, 05 Dec 2007 01:43:01 -0800 (PST)
Message-ID: <20071205.014301.179937807.davem@davemloft.net>
References: <4755256F.9000505@openvz.org>
	<47552779.40907@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38339
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751806AbXLEJnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 04:43:03 -0500
In-Reply-To: <47552779.40907@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 04 Dec 2007 13:10:01 +0300

> I have removed all the entries from this table (core_table,
> ipv4_table and tr_table), so now we can safely drop it.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.

Thanks Pavel.
