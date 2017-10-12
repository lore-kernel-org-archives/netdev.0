From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] veth: tweak creation of veth device
Date: Thu, 12 Oct 2017 10:19:54 -0700 (PDT)
Message-ID: <20171012.101954.1416857673514626860.davem@davemloft.net>
References: <1507666124-8780-1-git-send-email-mrv@mojatatu.com>
        <20171011.151706.1844884518098480593.davem@davemloft.net>
        <85tvz4wbtq.fsf@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org
To: mrv@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53430 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755591AbdJLRTz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:19:55 -0400
In-Reply-To: <85tvz4wbtq.fsf@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Mashak <mrv@mojatatu.com>
Date: Thu, 12 Oct 2017 12:49:37 -0400

> IMO, neither of these solutions seem reasonable.

I think the current behavior is reasonable.  The user is given tools,
one of which does dynamic allocation of names, and the user must simply
take that into consideration.
