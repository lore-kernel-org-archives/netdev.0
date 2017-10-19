From: Steve Lin <steven.lin1@broadcom.com>
Subject: Re: [PATCH net-next v2 6/6] bnxt: Add devlink support for config get/set
Date: Thu, 19 Oct 2017 16:40:36 -0400
Message-ID: <CA+Jmh7Ee-=6L7TEsNMmU_5O40x9FrkTHmoR8e7WoozHT2ngYjg@mail.gmail.com>
References: <1508440630-25830-1-git-send-email-steven.lin1@broadcom.com>
 <1508440630-25830-7-git-send-email-steven.lin1@broadcom.com> <20171019193514.GF1978@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        John Linville <linville@tuxdriver.com>,
        Andy Gospodarek <gospo@broadcom.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:56284 "EHLO
        mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753782AbdJSUk5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 16:40:57 -0400
Received: by mail-qk0-f176.google.com with SMTP id x82so11992259qkb.12
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 13:40:57 -0700 (PDT)
In-Reply-To: <20171019193514.GF1978@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 3:35 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Thu, Oct 19, 2017 at 09:17:10PM CEST, steven.lin1@broadcom.com wrote:
>>Implements get and set of configuration parameters using new devlink
>>config get/set API.
>
> Please split this patch too. One to introduce the infra, one per each
> config option.

Ok, will do in v3, thanks.
