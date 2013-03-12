From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 2013-03-11
Date: Tue, 12 Mar 2013 11:37:02 -0400 (EDT)
Message-ID: <20130312.113702.2235058521802126828.davem@davemloft.net>
References: <1363039948-27190-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54072 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932111Ab3CLPgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 11:36:51 -0400
In-Reply-To: <1363039948-27190-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Mon, 11 Mar 2013 23:12:27 +0100

> This is a single fix intended for net/linux-3.9 brought by Marek Lindner.
> It ensures that the incoming originator message parsing routine does not
> try to read beyond the packet boundary causing it to process random data.
> 
> This bug is in since a while..Please, consider sending this patch to stable.
> 
> 
> Please pull or let me know if there is any problem!

Pulled and queued up for -stable.
