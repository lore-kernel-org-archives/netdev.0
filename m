From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-next-2.6]: tcpv6: fix error with CONFIG_TCP_MD5SIG
 disabled
Date: Fri, 10 Oct 2008 15:05:35 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810101503570.1034@wrl-59.cs.helsinki.fi>
References: <20081008.195524.235036900.davem@davemloft.net>
 <20081010031703.M9440@cooldavid.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Guo-Fu Tseng <cooldavid@cooldavid.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41730 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753442AbYJJMFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 08:05:39 -0400
In-Reply-To: <20081010031703.M9440@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Oct 2008, Guo-Fu Tseng wrote:

>     This patch fix error with CONFIG_TCP_MD5SIG disabled.

Thanks for the fix, I realized (just before falling a sleep) that this 
would happen after my changes...

-- 
 i.
