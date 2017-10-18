From: Steve Lin <steven.lin1@broadcom.com>
Subject: Re: [PATCH 6/7] bnxt: Move generic devlink code to new file
Date: Wed, 18 Oct 2017 08:39:48 -0400
Message-ID: <CA+Jmh7G1BY+S7vbCFTUYDV=nT4J9DygO1dcvmuO38Df1tySCYg@mail.gmail.com>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
 <1508273069-40461-7-git-send-email-steven.lin1@broadcom.com> <20171018073348.GD2028@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        John Linville <linville@tuxdriver.com>,
        Andy Gospodarek <gospo@broadcom.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f180.google.com ([209.85.216.180]:55422 "EHLO
        mail-qt0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934046AbdJRMkJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 08:40:09 -0400
Received: by mail-qt0-f180.google.com with SMTP id v41so9940837qtv.12
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 05:40:09 -0700 (PDT)
In-Reply-To: <20171018073348.GD2028@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 18, 2017 at 3:33 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Oct 17, 2017 at 10:44:28PM CEST, steven.lin1@broadcom.com wrote:
>>Moving generic devlink code (registration) out of VR-R code
>>into new bnxt_devlink file.
>
> You can send this patch separatelly and let it be applied before the
> patchset.

Ok, will do.  Thanks again for all the feedback, Jiri.

Steve
