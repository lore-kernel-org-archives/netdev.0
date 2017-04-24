From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/2] flow_dissector: add mpls support (v2)
Date: Mon, 24 Apr 2017 09:05:56 +0200
Message-ID: <20170424070556.GC1886@nanopsycho.orion>
References: <1492894367-11637-1-git-send-email-benjamin.lahaise@netronome.com>
 <1492894367-11637-2-git-send-email-benjamin.lahaise@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Benjamin LaHaise <bcrl@kvack.org>,
        "David S. Miller" <davem@davemloft.net>,
        Simon Horman <simon.horman@netronome.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Gao Feng <fgao@ikuai8.com>
To: Benjamin LaHaise <benjamin.lahaise@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36672 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1165916AbdDXHF7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 03:05:59 -0400
Received: by mail-wm0-f65.google.com with SMTP id u65so15083458wmu.3
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 00:05:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1492894367-11637-2-git-send-email-benjamin.lahaise@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Apr 22, 2017 at 10:52:46PM CEST, benjamin.lahaise@netronome.com wrote:
>Add support for parsing MPLS flows to the flow dissector in preparation for
>adding MPLS match support to cls_flower.
>
>Signed-off-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>
>Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

This looks odd :)


>Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
