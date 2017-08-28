From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Revert "ipv4: make net_protocol const"
Date: Mon, 28 Aug 2017 14:01:33 -0700 (PDT)
Message-ID: <20170828.140133.2126200702424568912.davem@davemloft.net>
References: <1503951789-31836-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhumirks@gmail.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48216 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751182AbdH1VBf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 17:01:35 -0400
In-Reply-To: <1503951789-31836-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Mon, 28 Aug 2017 13:23:09 -0700

> This reverts commit aa8db499ea67cff1f5f049033810ffede2fe5ae4.
...
> I think this is the second time such a patch has been reverted.

Then please add a comment, it will help prevent this from happening
again.
