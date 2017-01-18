From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH iproute2 net-next] tc: flower: support matching flags
Date: Wed, 18 Jan 2017 13:41:03 +0100
Message-ID: <20170118134103.351bd524@griffin>
References: <1482930409-55059-1-git-send-email-paulb@mellanox.com>
        <20170102195522.7488179b@griffin>
        <1ec4f4ca-08e0-84fc-34c6-b3868d756050@mellanox.com>
        <20170104103301.GA30008@penelope.horms.nl>
        <82df989f-09a7-a89a-a675-c45d190b049e@mellanox.com>
        <20170104125559.34a7b7ed@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <simon.horman@netronome.com>,
        <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Paul Blakey <paulb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55032 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753281AbdARNEN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 08:04:13 -0500
In-Reply-To: <20170104125559.34a7b7ed@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 4 Jan 2017 12:55:59 +0100, Jiri Benc wrote:
> On Wed, 4 Jan 2017 13:51:13 +0200, Paul Blakey wrote:
> > It mimics the kernel packing of flags, I have no problem either way 
> > (flags, or ip_flags/tcp_flags pairs), what do you think jiri?
> 
> What Simon says makes sense to me. ip_flags and tcp_flags sounds like
> the best solution so far (even better than my original suggestion).

Is there any progress with the follow up patch? I don't think we want
iproute2 with the magic numbers to be released.

Thanks,

 Jiri
