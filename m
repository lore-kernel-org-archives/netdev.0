From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2/net-next repost] devlink: Add support for
 pipeline debug (dpipe)
Date: Sat, 15 Apr 2017 10:59:03 +0200
Message-ID: <20170415085903.GA2142@nanopsycho.orion>
References: <1490714657-6116-1-git-send-email-jiri@resnulli.us>
 <1490714814-6724-1-git-send-email-jiri@resnulli.us>
 <20170412164525.1c0468d0@xeon-e3>
 <20170413093027.GA1961@nanopsycho>
 <20170414160138.5f218c11@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, arkadis@mellanox.com,
        idosch@mellanox.com, mlxsw@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, roopa@cumulusnetworks.com,
        f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        john.fastabend@gmail.com, andrew@lunn.ch,
        simon.horman@netronome.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33285 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751511AbdDOI7H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2017 04:59:07 -0400
Received: by mail-wm0-f68.google.com with SMTP id o81so1740522wmb.0
        for <netdev@vger.kernel.org>; Sat, 15 Apr 2017 01:59:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170414160138.5f218c11@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Apr 15, 2017 at 01:01:38AM CEST, stephen@networkplumber.org wrote:
>On Thu, 13 Apr 2017 11:30:27 +0200
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> We actually took this code from teamdctl (at least it was an influence).
>> Devlink style is so much different in every aspect from the rest of the
>> iproute2 suite. And I did it on purpose, because it is much nicer and
>> easier to read. I would like to continue on this and don't do things in
>> the was the existing tools do. I don't see any problem with that.
>
>No. That is road to ruin. Every package is free to use what ever style
>it wants. But don't crossover please.

So we are stuck with some ugly way just because some other util does it?
Well, in devlink I wrote lot of things differently, nicer. For example
cmdline parsing. Why is it a "road to ruin"?
