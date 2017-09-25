From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sch_netem: faster rb tree removal
Date: Mon, 25 Sep 2017 13:11:01 -0700 (PDT)
Message-ID: <20170925.131101.478664536826772174.davem@davemloft.net>
References: <aa146e80-4cfd-888f-f6d2-bf4ec0eb7373@gmail.com>
        <1506317240.6617.5.camel@edumazet-glaptop3.roam.corp.google.com>
        <ce328dfd-0b54-883a-36a8-91ec344f86ad@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
        stephen@networkplumber.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58504 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751001AbdIYULF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 16:11:05 -0400
In-Reply-To: <ce328dfd-0b54-883a-36a8-91ec344f86ad@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Mon, 25 Sep 2017 10:14:23 -0600

> I made a simple program this morning and ran it under perf.

If possible please submit this for selftests.

Thank you.
