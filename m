From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SCTP: Free the per-net sysctl table on net exit. v2
Date: Tue, 05 Mar 2013 14:32:33 -0500 (EST)
Message-ID: <20130305.143233.739103204837913775.davem@davemloft.net>
References: <87libe3w69.fsf@xmission.com>
	<87obgayoo8.fsf_-_@xmission.com>
	<5135B542.8020905@fold.natur.cuni.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, vyasevich@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, stable@kernel.org
To: mmokrejs@fold.natur.cuni.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53343 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755Ab3CETcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 14:32:36 -0500
In-Reply-To: <5135B542.8020905@fold.natur.cuni.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>
Date: Tue, 05 Mar 2013 10:05:06 +0100

>   this is to let you know that this patch is still not in stable.
> I just fetched 3.7.10 and reproduced the original problem.

3.7.x is end of life and no longer being actively maintained.
