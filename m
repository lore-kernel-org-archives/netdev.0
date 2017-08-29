From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] nsh: headers, GSO
Date: Tue, 29 Aug 2017 15:17:07 -0700 (PDT)
Message-ID: <20170829.151707.1911972805135395713.davem@davemloft.net>
References: <cover.1503948295.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yi.y.yang@intel.com, e@erig.me,
        jan.scheurich@ericsson.com, blp@ovn.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40282 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751310AbdH2WRJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 18:17:09 -0400
In-Reply-To: <cover.1503948295.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Mon, 28 Aug 2017 21:43:20 +0200

> This adds header structs and helpers for NSH together with GSO support.
> 
> Note there is no code in this patchset that actually manipulates the NSH
> headers. That was sent to netdev by Yi Yang ("[PATCH net-next v6 0/3]
> openvswitch: add NSH support"). The aim of this series is to lay the
> groundwork and ease the implementation for him.
> 
> In addition to openvswitch, the NSH support should be added to tc (flower to
> match, act_nsh to push/pop NSH headers). That will come later. There's
> currently no plan to support NSH by other means than those two.
> 
> The patch 3 in this patchset was written by Yi Yang, I took it from the
> aforementioned series and slightly modified it - see the note in the patch.

Series applied, thanks Jiri.
