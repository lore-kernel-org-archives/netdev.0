From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/2] Fixes for raw diag sockets handling
Date: Thu, 03 Nov 2016 15:26:50 -0400 (EDT)
Message-ID: <20161103.152650.1086274425116533256.davem@davemloft.net>
References: <20161102123630.784612652@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        dsa@cumulusnetworks.com, avagin@openvz.org,
        stephen@networkplumber.org
To: gorcunov@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41412 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752754AbcKCT0x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 15:26:53 -0400
In-Reply-To: <20161102123630.784612652@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cyrill Gorcunov <gorcunov@openvz.org>
Date: Wed, 02 Nov 2016 15:36:30 +0300

> Hi! Here are a few fixes for raw-diag sockets handling: missing
> sock_put call and jump for exiting from nested cycle. I made
> patches for iproute2 as well so will send them out soon.

Series applied, thanks.
