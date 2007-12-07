From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] Remove ip_fib_local_table and ip_fib_main_table
 defines
Date: Fri, 07 Dec 2007 00:46:21 -0800 (PST)
Message-ID: <20071207.004621.13302830.davem@davemloft.net>
References: <20071206145825.GA22435@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, devel@openvz.org,
	netdev@vger.kernel.org, ebiederm@xmission.com
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58603
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751144AbXLGIqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 03:46:22 -0500
In-Reply-To: <20071206145825.GA22435@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 6 Dec 2007 17:58:25 +0300

> From: Eric W. Biederman <ebiederm@xmission.com>
> 
> There are only 2 users and it doesn't hurt to call fib_get_table
> instead, and it makes it easier to make the fib network namespace
> aware.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks.
