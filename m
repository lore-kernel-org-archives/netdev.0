From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net PATCH] bnxt_en: check for ingress qdisc in flower offload
Date: Mon, 18 Sep 2017 13:56:19 +0200
Message-ID: <20170918115619.GC1951@nanopsycho.orion>
References: <1505734537-6695-1-git-send-email-sathya.perla@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com
To: Sathya Perla <sathya.perla@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:48370 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753006AbdIRL4V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 07:56:21 -0400
Received: by mail-wr0-f181.google.com with SMTP id 108so256244wra.5
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 04:56:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1505734537-6695-1-git-send-email-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Sep 18, 2017 at 01:35:37PM CEST, sathya.perla@broadcom.com wrote:
>Check for ingress-only qdisc for flower offload, as other qdiscs
>are not supported for flower offload.
>
>Suggested-by: Jiri Pirko <jiri@resnulli.us>
>Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>

Reviewed-by: Jiri Pirko <jiri@mellanox.com>
