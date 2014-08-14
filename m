From: David Miller <davem@redhat.com>
Subject: Re: [PATCH 0/4] rhashtable annotation fixes
Date: Thu, 14 Aug 2014 15:14:04 -0700 (PDT)
Message-ID: <20140814.151404.1792648019765326707.davem@redhat.com>
References: <cover.1407939963.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58937 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753318AbaHNWOb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 18:14:31 -0400
In-Reply-To: <cover.1407939963.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 13 Aug 2014 16:38:28 +0200

> Thomas Graf (4):
>   rhashtable: RCU annotations for next pointers
>   rhashtable: unexport and make rht_obj() static
>   rhashtable: fix annotations for rht_for_each_entry_rcu()
>   netlink: Annotate RCU locking for seq_file walker

Series applied, thanks Thomas.
