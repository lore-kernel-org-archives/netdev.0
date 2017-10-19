From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 6/6] bnxt: Add devlink support for config
 get/set
Date: Thu, 19 Oct 2017 21:35:14 +0200
Message-ID: <20171019193514.GF1978@nanopsycho.orion>
References: <1508440630-25830-1-git-send-email-steven.lin1@broadcom.com>
 <1508440630-25830-7-git-send-email-steven.lin1@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com, davem@davemloft.net,
        michael.chan@broadcom.com, linville@tuxdriver.com,
        gospo@broadcom.com
To: Steve Lin <steven.lin1@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:44112 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751772AbdJSTfQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 15:35:16 -0400
Received: by mail-wm0-f48.google.com with SMTP id 196so17121755wma.1
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 12:35:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1508440630-25830-7-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 19, 2017 at 09:17:10PM CEST, steven.lin1@broadcom.com wrote:
>Implements get and set of configuration parameters using new devlink
>config get/set API.

Please split this patch too. One to introduce the infra, one per each
config option.
