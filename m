From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 0/5] printk message cleanup's
Date: Fri, 29 Aug 2014 00:09:18 -0700
Message-ID: <20140829070918.508987897@networkplumber.org>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:50622 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983AbaH2HK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 03:10:28 -0400
Received: by mail-pa0-f41.google.com with SMTP id lj1so5972497pab.0
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2014 00:10:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To support space and clutter reduction get rid of some useless
messages on boot, and be more precise about message level,
and don't use bare printk in network code.
