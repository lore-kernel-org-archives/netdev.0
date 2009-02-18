From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/43] drivers/net/ni65.c: fix sparse warnings: fix
 signedness
Date: Tue, 17 Feb 2009 17:21:58 -0800 (PST)
Message-ID: <20090217.172158.45165350.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214211332.23489.25144.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47829
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753496AbZBRBWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 20:22:14 -0500
In-Reply-To: <20090214211332.23489.25144.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sat, 14 Feb 2009 22:13:39 +0100

> Fix this sparse warnings:
>   drivers/net/ni65.c:488:36: warning: incorrect type in argument 2 (different signedness)
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
