From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/16] net: remove unnecessary break after goto/return
Date: Tue, 15 Jul 2014 16:27:31 -0700 (PDT)
Message-ID: <20140715.162731.976775911116907392.davem@davemloft.net>
References: <1405355467-7350-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, joe@perches.com,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	linux-s390@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-nfc@lists.01.org, linux-sctp@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: fabf@skynet.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45566 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965065AbaGOX1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 19:27:34 -0400
In-Reply-To: <1405355467-7350-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabian Frederick <fabf@skynet.be>
Date: Mon, 14 Jul 2014 18:30:50 +0200

> Small patchset addressing break redundancy on net branch
> (suggested by Joe Perches).

Series applied, thanks Fabian.
