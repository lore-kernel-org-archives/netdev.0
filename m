From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/2] cls_flower: add support for matching MPLS
 fields (v2)
Date: Mon, 24 Apr 2017 09:07:15 +0200
Message-ID: <20170424070715.GD1886@nanopsycho.orion>
References: <1492894367-11637-1-git-send-email-benjamin.lahaise@netronome.com>
 <1492894367-11637-3-git-send-email-benjamin.lahaise@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Benjamin LaHaise <bcrl@kvack.org>,
        "David S. Miller" <davem@davemloft.net>,
        Simon Horman <simon.horman@netronome.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Eric Dumazet <edumazet@google.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Gao Feng <fgao@ikuai8.com>
To: Benjamin LaHaise <benjamin.lahaise@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34199 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1165505AbdDXHHS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 03:07:18 -0400
Received: by mail-wm0-f66.google.com with SMTP id z129so15107756wmb.1
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 00:07:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1492894367-11637-3-git-send-email-benjamin.lahaise@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Apr 22, 2017 at 10:52:47PM CEST, benjamin.lahaise@netronome.com wrote:
>Add support to the tc flower classifier to match based on fields in MPLS
>labels (TTL, Bottom of Stack, TC field, Label).
>
>Signed-off-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>
>Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
>Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
