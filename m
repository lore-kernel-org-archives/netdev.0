From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/2] fib_trie: Minor fixes for table merge
Date: Thu, 12 Mar 2015 18:28:43 -0400 (EDT)
Message-ID: <20150312.182843.249326251613480794.davem@davemloft.net>
References: <20150312214226.1133.9622.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41159 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751040AbbCLW2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 18:28:46 -0400
In-Reply-To: <20150312214226.1133.9622.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Thu, 12 Mar 2015 14:46:17 -0700

> This patch set addresses two issues reported with the tables merged, the
> first is a NULL pointer dereference, and the other is to remove a WARN_ON
> and set the ordering for aliases from different tables with the same slen
> values.

Looks great, series applied, thanks for fixing these so fast!
