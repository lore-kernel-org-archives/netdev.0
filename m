From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/4 v2] ipvlan: list corruption and rcu fixes
Date: Tue, 31 Mar 2015 13:29:03 -0400 (EDT)
Message-ID: <20150331.132903.859032704153847955.davem@davemloft.net>
References: <cover.1427566140.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maheshb@google.com, dcbw@redhat.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48768 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753918AbbCaR3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 13:29:05 -0400
In-Reply-To: <cover.1427566140.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Sat, 28 Mar 2015 19:13:21 +0100

> This patch set fixes different issues leading to corrupted lists and
> incorrect rcu usage.
> 
> Only patch 1/4 changed since the last submission.

Series applied, thanks alot.
