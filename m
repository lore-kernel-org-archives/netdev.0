From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 6/7] bnxt: Move generic devlink code to new file
Date: Wed, 18 Oct 2017 09:33:48 +0200
Message-ID: <20171018073348.GD2028@nanopsycho>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
 <1508273069-40461-7-git-send-email-steven.lin1@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com, davem@davemloft.net,
        michael.chan@broadcom.com, linville@tuxdriver.com,
        gospo@broadcom.com
To: Steve Lin <steven.lin1@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:51065 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762647AbdJRHdu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 03:33:50 -0400
Received: by mail-wm0-f45.google.com with SMTP id u138so8083484wmu.5
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 00:33:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1508273069-40461-7-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 17, 2017 at 10:44:28PM CEST, steven.lin1@broadcom.com wrote:
>Moving generic devlink code (registration) out of VR-R code
>into new bnxt_devlink file.

You can send this patch separatelly and let it be applied before the
patchset.
