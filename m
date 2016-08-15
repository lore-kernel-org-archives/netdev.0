From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] switchdev: Put export declaration in the
 right place
Date: Mon, 15 Aug 2016 13:38:09 -0700 (PDT)
Message-ID: <20160815.133809.190925026743453165.davem@davemloft.net>
References: <1471261914-32183-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45218 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932115AbcHOUiK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 16:38:10 -0400
In-Reply-To: <1471261914-32183-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Mon, 15 Aug 2016 14:51:54 +0300

> Move exporting of switchdev_port_same_parent_id to be right
> below it and not elsewhere.
> 
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Reported-by: Ido Schimmel <idosch@mellanox.com>

Applied, thank you.
