From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2/net-next repost] devlink: Add support for
 pipeline debug (dpipe)
Date: Fri, 14 Apr 2017 16:01:38 -0700
Message-ID: <20170414160138.5f218c11@xeon-e3>
References: <1490714657-6116-1-git-send-email-jiri@resnulli.us>
        <1490714814-6724-1-git-send-email-jiri@resnulli.us>
        <20170412164525.1c0468d0@xeon-e3>
        <20170413093027.GA1961@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, arkadis@mellanox.com,
        idosch@mellanox.com, mlxsw@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, roopa@cumulusnetworks.com,
        f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        john.fastabend@gmail.com, andrew@lunn.ch,
        simon.horman@netronome.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:36111 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752277AbdDNXBl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 19:01:41 -0400
Received: by mail-pg0-f54.google.com with SMTP id g2so48175103pge.3
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 16:01:40 -0700 (PDT)
In-Reply-To: <20170413093027.GA1961@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Apr 2017 11:30:27 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> We actually took this code from teamdctl (at least it was an influence).
> Devlink style is so much different in every aspect from the rest of the
> iproute2 suite. And I did it on purpose, because it is much nicer and
> easier to read. I would like to continue on this and don't do things in
> the was the existing tools do. I don't see any problem with that.

No. That is road to ruin. Every package is free to use what ever style
it wants. But don't crossover please.
