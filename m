From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: introduce SO_PEERGROUPS getsockopt
Date: Wed, 21 Jun 2017 11:41:29 -0400 (EDT)
Message-ID: <20170621.114129.1938918065517274748.davem@davemloft.net>
References: <20170621084715.17772-1-dh.herrmann@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, teg@jklm.no, msekleta@redhat.com,
        simon.mcvittie@collabora.co.uk
To: dh.herrmann@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40454 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752990AbdFUQUs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 12:20:48 -0400
In-Reply-To: <20170621084715.17772-1-dh.herrmann@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Herrmann <dh.herrmann@gmail.com>
Date: Wed, 21 Jun 2017 10:47:15 +0200

> This adds the new getsockopt(2) option SO_PEERGROUPS on SOL_SOCKET to
> retrieve the auxiliary groups of the remote peer.
 ...

Looks good, applied, thanks.
