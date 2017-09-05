From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v7] openvswitch: enable NSH support
Date: Tue, 5 Sep 2017 11:47:41 +0200
Message-ID: <20170905114741.537dfc11@griffin>
References: <1504096752-102003-1-git-send-email-yi.y.yang@intel.com>
        <20170831124516.0c5db686@griffin>
        <20170904080005.GA70767@cran64.bj.intel.com>
        <20170904124216.6db68e8c@griffin>
        <20170905063705.GA89551@cran64.bj.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "e@erig.me" <e@erig.me>, "blp@ovn.org" <blp@ovn.org>,
        "jan.scheurich@ericsson.com" <jan.scheurich@ericsson.com>
To: "Yang, Yi" <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56874 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751150AbdIEJrp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 5 Sep 2017 05:47:45 -0400
In-Reply-To: <20170905063705.GA89551@cran64.bj.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 5 Sep 2017 14:37:05 +0800, Yang, Yi wrote:
> I checked source code but can't find where we can prepopulate it and how
> we can deliver the prepopulated header to push_nsh, can you expand it in
> order that I can know how to do this in code level?

I already said that it's not implemented yet and can be done as a
future performance enhancement.

 Jiri
