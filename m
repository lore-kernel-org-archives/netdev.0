From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next] team: add macro MODULE_ALIAS_TEAM_MODE for team mode
 alias
Date: Fri, 2 Jun 2017 10:10:25 +0200
Message-ID: <20170602081025.GA2015@nanopsycho.orion>
References: <1496302622-9958-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36719 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750807AbdFBIK2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 04:10:28 -0400
Received: by mail-wm0-f41.google.com with SMTP id 7so16154656wmo.1
        for <netdev@vger.kernel.org>; Fri, 02 Jun 2017 01:10:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1496302622-9958-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jun 01, 2017 at 09:37:02AM CEST, zhangshengju@cmss.chinamobile.com wrote:
>Add a new macro MODULE_ALIAS_TEAM_MODE to unify and simplify the
>declaration of team mode alias.
>
>Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
