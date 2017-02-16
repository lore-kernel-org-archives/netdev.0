From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/8] Add support for pipeline debug (dpipe)
Date: Thu, 16 Feb 2017 19:40:16 +0100
Message-ID: <20170216184016.GI1968@nanopsycho>
References: <1487258564-3775-1-git-send-email-jiri@resnulli.us>
 <20170216170446.GF17550@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, arkadis@mellanox.com,
        idosch@mellanox.com, mlxsw@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, roopa@cumulusnetworks.com,
        f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        john.fastabend@gmail.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:35339 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933275AbdBPSkT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 13:40:19 -0500
Received: by mail-wr0-f182.google.com with SMTP id c4so17788010wrd.2
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 10:40:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170216170446.GF17550@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 16, 2017 at 06:04:46PM CET, andrew@lunn.ch wrote:
>On Thu, Feb 16, 2017 at 04:22:36PM +0100, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>
>Hi Jiri, Arkadi
>
>Just to make sure we are all on the same page here:
>
>This purely RFC. It is not intended for the merge window starting next
>week?

No. We are aiming next net-next open.


>
>This is a new binary API, something we have to live with forever. So i
>think before it gets merged into a Linus kernel, we need time to think
>about all the different sorts of tables we want to dump, what sort of
>fields they have, and can we represent them using this API. That is
>going to take some time.

Agreed.
