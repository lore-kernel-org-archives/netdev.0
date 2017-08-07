From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] iproute: Add support for extended ack to rtnl_talk
Date: Mon, 07 Aug 2017 13:26:03 -0700 (PDT)
Message-ID: <20170807.132603.2058256055534574552.davem@davemloft.net>
References: <bd0ad410-9b64-6f1b-6f78-08f6e801628b@gmail.com>
        <20170807.114517.1570408214504753399.davem@davemloft.net>
        <20170807121235.4a8b5020@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsahern@gmail.com, simon.horman@netronome.com,
        daniel@iogearbox.net, phil@nwl.cc, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35326 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751505AbdHGU0G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 16:26:06 -0400
In-Reply-To: <20170807121235.4a8b5020@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 7 Aug 2017 12:12:35 -0700

> Dave, I asked for test cases, and received none.

You don't need a test case to type make and make sure the build succeeds.
