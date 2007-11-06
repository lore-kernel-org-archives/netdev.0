From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -net 1/2] Convert /proc/net/ipv6_route to seq_file
 interface
Date: Tue, 06 Nov 2007 05:27:18 -0800 (PST)
Message-ID: <20071106.052718.14115111.davem@davemloft.net>
References: <20071106122150.GA6215@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: adobriyan@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49136
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751079AbXKFN1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 08:27:20 -0500
In-Reply-To: <20071106122150.GA6215@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@sw.ru>
Date: Tue, 6 Nov 2007 15:21:50 +0300

> This removes last proc_net_create() user. Kudos to Benjamin Thery and
> Stephen Hemminger for comments on previous version.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>

Applied.
