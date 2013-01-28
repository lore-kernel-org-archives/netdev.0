From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SCTP: Free the per-net sysctl table on net exit. v2
Date: Mon, 28 Jan 2013 00:11:25 -0500 (EST)
Message-ID: <20130128.001125.1697434398997976656.davem@davemloft.net>
References: <20130127.193511.2294954038548420781.davem@davemloft.net>
	<87libe3w69.fsf@xmission.com>
	<87obgayoo8.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, mmokrejs@fold.natur.cuni.cz
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39053 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785Ab3A1FL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 00:11:29 -0500
In-Reply-To: <87obgayoo8.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sun, 27 Jan 2013 19:25:11 -0800

> The typo is fixed in the patch this time in addition to my test
> tree.

Applied, thanks for fixing this up Eric.
