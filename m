From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/2] team: two RCU fixups
Date: Wed, 20 Jun 2012 14:05:16 -0700 (PDT)
Message-ID: <20120620.140516.2004640533824596305.davem@davemloft.net>
References: <1340206321-5986-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jbrouer@redhat.com,
	paulmck@linux.vnet.ibm.com, wfg@linux.intel.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45168 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755082Ab2FTVFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 17:05:17 -0400
In-Reply-To: <1340206321-5986-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 20 Jun 2012 17:31:59 +0200

> Jiri Pirko (2):
>   team: use rcu_access_pointer to access RCU pointer by writer
>   team: use RCU_INIT_POINTER for NULL assignment of RCU pointer

Applied, but this makes your subsequent patch not apply.
