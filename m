From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] xt_helper: use sizeof()
Date: Fri, 23 Jul 2010 13:53:19 +0200
Message-ID: <4C4982AF.7020001@trash.net>
References: <1279873323-15544-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36325 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758421Ab0GWLxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 07:53:13 -0400
In-Reply-To: <1279873323-15544-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23.07.2010 10:22, Changli Gao wrote:
> use sizeof() to improve the readability.
> 

Applied, thanks.

One more request about your changelogs though: please use capital
letters at the beginning of new sentences in the patch description.
