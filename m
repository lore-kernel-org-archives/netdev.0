From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib_trie: use seq_file_net rather than seq->private
Date: Mon, 02 Jun 2014 16:43:16 -0700 (PDT)
Message-ID: <20140602.164316.804260910451090978.davem@davemloft.net>
References: <1401478479-77986-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37777 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752786AbaFBXnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 19:43:17 -0400
In-Reply-To: <1401478479-77986-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Fri, 30 May 2014 13:34:39 -0600

> Make fib_triestat_seq_show consistent with other /proc/net files and
> use seq_file_net.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied to net-next, thanks.
