From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/3] ipv4: Fix ip-header identification for gso
 packets.
Date: Tue, 26 Mar 2013 13:50:59 -0400 (EDT)
Message-ID: <20130326.135059.291297213736849015.davem@davemloft.net>
References: <1364182589-1766-1-git-send-email-pshelar@nicira.com>
	<CALnjE+qAo5GsnTP=EU87N7KHWXE8UWnhn4HtV16tDJ00SnsKzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amwang@redhat.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42283 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756566Ab3CZRvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 13:51:04 -0400
In-Reply-To: <CALnjE+qAo5GsnTP=EU87N7KHWXE8UWnhn4HtV16tDJ00SnsKzw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@nicira.com>
Date: Tue, 26 Mar 2013 10:34:17 -0700

> This issue is present in net-tree. Can you apply this patch net-tree?

Good point, applied to 'net', thanks.
