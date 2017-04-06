From: David Miller <davem@davemloft.net>
Subject: Re: [git pull] skb_copy_{,and_csum_}datagram_msg() fixes
Date: Thu, 06 Apr 2017 11:57:57 -0700 (PDT)
Message-ID: <20170406.115757.1061953395565358353.davem@davemloft.net>
References: <20170402162328.GH29622@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36012 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932990AbdDFS6C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 14:58:02 -0400
In-Reply-To: <20170402162328.GH29622@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Sun, 2 Apr 2017 17:23:28 +0100

> 	Fixes rsync et.al. regression since 3.19...

Pulled, thanks Al.
