From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] strp: Minor fixes to strparser and kcm
Date: Tue, 23 Aug 2016 16:23:27 -0700 (PDT)
Message-ID: <20160823.162327.678610350116333787.davem@davemloft.net>
References: <1471978531-3231140-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55725 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752826AbcHWXXu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 19:23:50 -0400
In-Reply-To: <1471978531-3231140-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 23 Aug 2016 11:55:29 -0700

> Fix locking issue in kcm and losing events when paused.

Series applied, thanks Tom.
