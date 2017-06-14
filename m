From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [patch iproute2 v2 repost 2/3] tc: actions: add helpers to
 parse and print control actions
Date: Wed, 14 Jun 2017 21:28:24 +0200
Message-ID: <20170614212824.757ca744@griffin>
References: <20170516172802.1317-1-jiri@resnulli.us>
        <20170516172937.1391-2-jiri@resnulli.us>
        <20170614203222.3dcc183d@griffin>
        <20170614191850.GA1972@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, dsa@cumulusnetworks.com,
        edumazet@google.com, stephen@networkplumber.org,
        daniel@iogearbox.net, alexander.h.duyck@intel.com,
        simon.horman@netronome.com, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33520 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751960AbdFNT22 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 15:28:28 -0400
In-Reply-To: <20170614191850.GA1972@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Jun 2017 21:18:50 +0200, Jiri Pirko wrote:
> Isn't it fixed by:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git/commit/?h=net-next&id=18f05d06016d9492c87fd105d831de0d6d858f43
> 
> ?

Doesn't seem so. The current net-next branch with this commit included
fails in the same way.

 Jiri
