From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/6] bonding: prepare to and add
 arp_all_targets
Date: Tue, 25 Jun 2013 16:59:00 -0700 (PDT)
Message-ID: <20130625.165900.1252114206200126763.davem@davemloft.net>
References: <1372067374-10459-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	linux@8192.net, nicolas.2p.debian@free.fr, rick.jones2@hp.com,
	nikolay@redhat.com, mkubecek@suse.cz
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35294 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752363Ab3FYX7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 19:59:01 -0400
In-Reply-To: <1372067374-10459-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Mon, 24 Jun 2013 11:49:28 +0200

> This patchset does some cleanup, fixes a few flaws and adds a new parameter
> to control whether the slave should stay up when any of arp_ip_targets are
> up or all of them are up (i.e. if the slave should go down if even one
> target from arp_ip_targets fail).
> 
> The patches 1-5 basically prepare the bonding code to work properly with this
> new parameter, however it's not depending on them.
> 
> All comments are really welcome.

Series applied, thank you.
