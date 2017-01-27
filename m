From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] net: Fix ndo_setup_tc comment
Date: Fri, 27 Jan 2017 08:12:38 +0100
Message-ID: <20170127071238.GA1902@nanopsycho>
References: <20170126224417.10327-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        john.r.fastabend@intel.com, jiri@mellanox.com, jhs@mojatatu.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33942 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754002AbdA0HTT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 02:19:19 -0500
Received: by mail-wm0-f68.google.com with SMTP id c85so55928159wmi.1
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 23:18:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170126224417.10327-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jan 26, 2017 at 11:44:17PM CET, f.fainelli@gmail.com wrote:
>Commit 16e5cc647173 ("net: rework setup_tc ndo op to consume
>general tc operand") changed the ndo_setup_tc() signature, but did not
>update the comments in netdevice.h, so do that now.
>
>Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Jiri Pirko <jiri@mellanox.com>
