From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] prandom fixes/improvements
Date: Mon, 11 Nov 2013 14:33:41 -0500 (EST)
Message-ID: <20131111.143341.148954332177473990.davem@davemloft.net>
References: <cover.1384160397.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@networkplumber.org, fweimer@redhat.com,
	netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57073 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754321Ab3KKTdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 14:33:47 -0500
In-Reply-To: <cover.1384160397.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 11 Nov 2013 12:20:31 +0100

> It would be great if you could still consider this series that fixes and
> improves prandom for 3.13. We have sent it to netdev as prandom() originally
> came from net/core/utils.c and networking is its main user. For a detailled
> description, please see individual patches.

Ok, series applied, I'll give Linus the merge conflict resolution
instructions.

Thanks!
