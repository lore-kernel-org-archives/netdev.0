From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC] iproute: Add support for extended ack to rtnl_talk
Date: Mon, 7 Aug 2017 14:21:13 -0700
Message-ID: <20170807142113.66347c79@xeon-e3>
References: <bd0ad410-9b64-6f1b-6f78-08f6e801628b@gmail.com>
        <20170807.114517.1570408214504753399.davem@davemloft.net>
        <20170807121235.4a8b5020@xeon-e3>
        <20170807.132603.2058256055534574552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dsahern@gmail.com, simon.horman@netronome.com,
        daniel@iogearbox.net, phil@nwl.cc, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34772 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751662AbdHGVVP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 17:21:15 -0400
Received: by mail-pf0-f176.google.com with SMTP id o86so6208961pfj.1
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 14:21:15 -0700 (PDT)
In-Reply-To: <20170807.132603.2058256055534574552.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 07 Aug 2017 13:26:03 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Mon, 7 Aug 2017 12:12:35 -0700
> 
> > Dave, I asked for test cases, and received none.  
> 
> You don't need a test case to type make and make sure the build succeeds.

It did succeed for libmnl but was not doing anything.
