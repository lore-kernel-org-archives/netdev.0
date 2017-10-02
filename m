From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/2] flow_dissector: dissect tunnel info
Date: Mon, 2 Oct 2017 12:00:54 +0200
Message-ID: <20171002100054.GC1941@nanopsycho.orion>
References: <1506933676-20121-1-git-send-email-simon.horman@netronome.com>
 <1506933676-20121-3-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:50239 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751127AbdJBKA5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 06:00:57 -0400
Received: by mail-wm0-f65.google.com with SMTP id u138so9425750wmu.5
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 03:00:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1506933676-20121-3-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 02, 2017 at 10:41:16AM CEST, simon.horman@netronome.com wrote:
>Move dissection of tunnel info from the flower classifier to the flow
>dissector where all other dissection occurs.  This should not have any
>behavioural affect on other users of the flow dissector.
>
>Signed-off-by: Simon Horman <simon.horman@netronome.com>
>Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>

Thanks for fixing this up Simon!
