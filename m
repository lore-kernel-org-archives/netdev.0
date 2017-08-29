From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next] bnxt_en: add a dummy definition for bnxt_vf_rep_get_fid()
Date: Mon, 28 Aug 2017 23:22:23 -0700
Message-ID: <CACKFLimtt_rQpDqL9gOrrkAe5ZAZba1yndsUfpg5baF1RoHfsg@mail.gmail.com>
References: <1503987303-12392-1-git-send-email-sathya.perla@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>
To: Sathya Perla <sathya.perla@broadcom.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:35143 "EHLO
        mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750758AbdH2GWZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 02:22:25 -0400
Received: by mail-yw0-f172.google.com with SMTP id s187so12544834ywf.2
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 23:22:24 -0700 (PDT)
In-Reply-To: <1503987303-12392-1-git-send-email-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 28, 2017 at 11:15 PM, Sathya Perla
<sathya.perla@broadcom.com> wrote:
> When bnxt VF-reps are not compiled in (CONFIG_BNXT_SRIOV is off)
> bnxt_tc.c needs a dummy definition of the routine bnxt_vf_rep_get_fid().
>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Fixes: 2ae7408fedfe ("bnxt_en: bnxt: add TC flower filter offload support")
> Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
