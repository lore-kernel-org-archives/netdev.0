From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] vxlan: do not error out on disabled IPv6
Date: Sun, 30 Apr 2017 22:30:27 -0400 (EDT)
Message-ID: <20170430.223027.761459633304610982.davem@davemloft.net>
References: <cover.1493320999.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mleitner@redhat.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54228 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S642351AbdEACa3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 22:30:29 -0400
In-Reply-To: <cover.1493320999.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Thu, 27 Apr 2017 21:24:34 +0200

> This patchset fixes a bug with metadata based tunnels when booted with
> ipv6.disable=1.

Series applied, thanks.
