From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 16/43] drivers/net/cxgb3: fix sparse warning: symbol shadows
 an earlier one
Date: Sun, 15 Feb 2009 13:30:34 -0800
Message-ID: <4998897A.3030904@chelsio.com>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net> <20090214211557.23489.75670.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hannes Eder <hannes@hanneseder.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:14579 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754917AbZBOVai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2009 16:30:38 -0500
In-Reply-To: <20090214211557.23489.75670.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Eder wrote:
> Impact: Move variable declaration as close to usage as possible.
>
> Fix this sparse warning:
>   drivers/net/cxgb3/cxgb3_main.c:1586:21: warning: symbol 'cap' shadows an earlier one
>
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>
>   
Acked-by: Divy Le Ray <divy@chelsio.com>
