From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] rds: tcp: fixes
Date: Thu, 22 Jun 2017 11:34:21 -0400 (EDT)
Message-ID: <20170622.113421.2291917991900766092.davem@davemloft.net>
References: <cover.1498074496.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, santosh.shilimkar@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36282 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751193AbdFVPeX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 11:34:23 -0400
In-Reply-To: <cover.1498074496.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Wed, 21 Jun 2017 13:40:11 -0700

> Patch1 is a bug fix for correct reconnect when a connection
> is restarted. Patch 2 accelerates cleanup by setting linger
> to 1 and sending a RST to the peer.

Series applied, thanks.
