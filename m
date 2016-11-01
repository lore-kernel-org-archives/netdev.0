From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/2] net/sched: cls_flower: merge filter
 delete/destroy common code
Date: Tue, 1 Nov 2016 15:23:31 +0100
Message-ID: <20161101142331.GB1677@nanopsycho.orion>
References: <1478009309-63180-1-git-send-email-roid@mellanox.com>
 <1478009309-63180-3-git-send-email-roid@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>
To: Roi Dayan <roid@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36823 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966399AbcKAOXe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 10:23:34 -0400
Received: by mail-wm0-f66.google.com with SMTP id c17so22918337wmc.3
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 07:23:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1478009309-63180-3-git-send-email-roid@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 01, 2016 at 03:08:29PM CET, roid@mellanox.com wrote:
>Move common code from fl_delete and fl_detroy to __fl_delete.
>
>Signed-off-by: Roi Dayan <roid@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
