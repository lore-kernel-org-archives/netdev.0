From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] nfp: process MTU updates from firmware
 flower app
Date: Wed, 16 Aug 2017 11:36:59 -0700 (PDT)
Message-ID: <20170816.113659.599380793285418828.davem@davemloft.net>
References: <1502869064-25842-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        oss-drivers@netronome.com
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35150 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751635AbdHPSg7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 14:36:59 -0400
In-Reply-To: <1502869064-25842-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Wed, 16 Aug 2017 09:37:42 +0200

> The first patch of this series moves processing of control messages from a
> BH handler to a workqueue. That change makes it safe to process MTU
> updates from the firmware which is added by the second patch of this
> series.

Series applied, thanks.
