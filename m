From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] flow_dissector: dissect tunnel info
Date: Mon, 02 Oct 2017 11:06:25 -0700 (PDT)
Message-ID: <20171002.110625.1948498369722380419.davem@davemloft.net>
References: <1506933676-20121-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46398 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751199AbdJBSG0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 14:06:26 -0400
In-Reply-To: <1506933676-20121-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Mon,  2 Oct 2017 10:41:14 +0200

> Move dissection of tunnel info from the flower classifier to the flow
> dissector where all other dissection occurs.  This should not have any
> behavioural affect on other users of the flow dissector.

Series applied, thanks Simon.
