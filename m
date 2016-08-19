From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xen-netback: create a debugfs node for hash
 information
Date: Thu, 18 Aug 2016 23:29:23 -0700 (PDT)
Message-ID: <20160818.232923.1589062386391691533.davem@davemloft.net>
References: <1471446809-4845-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
        wei.liu2@citrix.com
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42408 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753571AbcHSG3Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 02:29:24 -0400
In-Reply-To: <1471446809-4845-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Wed, 17 Aug 2016 16:13:29 +0100

> It is useful to be able to see the hash configuration when running tests.
> This patch adds a debugfs node for that purpose.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>

Applied.
