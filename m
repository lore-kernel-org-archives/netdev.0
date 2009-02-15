From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 17/43] drivers/net/cxgb3: fix sparse warnings: fix signedness
Date: Sun, 15 Feb 2009 13:32:07 -0800
Message-ID: <499889D7.2070305@chelsio.com>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net> <20090214211612.23489.60993.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hannes Eder <hannes@hanneseder.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:14597 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752697AbZBOVcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2009 16:32:13 -0500
In-Reply-To: <20090214211612.23489.60993.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Eder wrote:
> Fix this sparse warning:
>   drivers/net/cxgb3/ael1002.c:1010:60: warning: incorrect type in argument 4 (different signedness)
>
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>
>   
Acked-by: Divy Le Ray <divy@chelsio.com>
