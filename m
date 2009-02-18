From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 43/43] drivers/net/wireless/prism54: fix sparse
 warning: fix signedness
Date: Tue, 17 Feb 2009 19:49:46 -0800 (PST)
Message-ID: <20090217.194946.175639509.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214215034.24377.54126.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55694
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755240AbZBRDuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 22:50:02 -0500
In-Reply-To: <20090214215034.24377.54126.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sat, 14 Feb 2009 22:50:45 +0100

> Fix sparse warning:
>   drivers/net/wireless/prism54/isl_ioctl.c:2997:32: warning: incorrect type in argument 2 (different signedness)
>   drivers/net/wireless/prism54/oid_mgt.c:712:42: warning: incorrect type in argument 2 (different signedness)
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
