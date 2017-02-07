From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 194241] New: LXC - setns() performance issue with more
 than 1vCPU
Date: Tue, 07 Feb 2017 11:34:34 -0500 (EST)
Message-ID: <20170207.113434.1899380468460794265.davem@davemloft.net>
References: <20170207083032.1882acd1@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51138 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754142AbdBGQef (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 11:34:35 -0500
In-Reply-To: <20170207083032.1882acd1@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 7 Feb 2017 08:30:32 -0800

>     Kernel Version: 3.6.57 , 3.16.7

Yeah, we've made thousands of network namespace performance
improvements since then.
