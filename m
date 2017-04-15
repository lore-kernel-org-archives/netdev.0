From: David Miller <davem@davemloft.net>
Subject: Re: [patch iproute2/net-next repost] devlink: Add support for
 pipeline debug (dpipe)
Date: Sat, 15 Apr 2017 09:57:05 -0400 (EDT)
Message-ID: <20170415.095705.1787032921503797059.davem@davemloft.net>
References: <20170413093027.GA1961@nanopsycho>
        <20170414160138.5f218c11@xeon-e3>
        <20170415085903.GA2142@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
        arkadis@mellanox.com, idosch@mellanox.com, mlxsw@mellanox.com,
        jhs@mojatatu.com, ivecera@redhat.com, roopa@cumulusnetworks.com,
        f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        john.fastabend@gmail.com, andrew@lunn.ch,
        simon.horman@netronome.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57570 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753242AbdDON5I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2017 09:57:08 -0400
In-Reply-To: <20170415085903.GA2142@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sat, 15 Apr 2017 10:59:03 +0200

> Sat, Apr 15, 2017 at 01:01:38AM CEST, stephen@networkplumber.org wrote:
>>On Thu, 13 Apr 2017 11:30:27 +0200
>>Jiri Pirko <jiri@resnulli.us> wrote:
>>
>>> We actually took this code from teamdctl (at least it was an influence).
>>> Devlink style is so much different in every aspect from the rest of the
>>> iproute2 suite. And I did it on purpose, because it is much nicer and
>>> easier to read. I would like to continue on this and don't do things in
>>> the was the existing tools do. I don't see any problem with that.
>>
>>No. That is road to ruin. Every package is free to use what ever style
>>it wants. But don't crossover please.
> 
> So we are stuck with some ugly way just because some other util does it?
> Well, in devlink I wrote lot of things differently, nicer. For example
> cmdline parsing. Why is it a "road to ruin"?

I agree with Jiri, if he wants to stylize devlink a certain way that
makes sense for devlink information, that is perfectly fine and does
not impact the way the rest of iproute2's output appears to the user
at all.
