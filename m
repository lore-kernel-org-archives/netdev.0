From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/2] net/sched: cls_flower: merge filter
 delete/destroy common code
Date: Tue, 1 Nov 2016 19:17:55 +0300
Message-ID: <f702d1a8-1bf0-a1b6-54e0-40f5e93fa989@cogentembedded.com>
References: <1478009309-63180-1-git-send-email-roid@mellanox.com>
 <1478009309-63180-3-git-send-email-roid@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>
To: Roi Dayan <roid@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:36409 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750927AbcKAQR7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 12:17:59 -0400
Received: by mail-lf0-f52.google.com with SMTP id t196so43839241lff.3
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 09:17:58 -0700 (PDT)
In-Reply-To: <1478009309-63180-3-git-send-email-roid@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/2016 05:08 PM, Roi Dayan wrote:

> Move common code from fl_delete and fl_detroy to __fl_delete.

    fl_destroy().


> Signed-off-by: Roi Dayan <roid@mellanox.com>
[...]

MBR, Sergei
