From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] geneve: Add support for Remote
 Checksum Offload
Date: Sun, 13 Dec 2015 23:59:39 -0500 (EST)
Message-ID: <20151213.235939.1867349644959138418.davem@davemloft.net>
References: <1449779673-3701191-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44115 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752338AbbLNE7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2015 23:59:46 -0500
In-Reply-To: <1449779673-3701191-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 10 Dec 2015 12:34:30 -0800

> This patch set adds UDP checksum configuration via netlink and
> Remote Checksum Offload for Geneve,
> 
> v2:
>   - Fix issue of taking sizeof a pointer instead of the actual object
>   - Fix type in commi log

Applied patches #1 and #2 only.

Patch #3 deferred as per Jesse's request.
