From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v6 net-next 0/7] Extend socket timestamping API
Date: Fri, 19 May 2017 22:15:27 +0200
Message-ID: <20170519201527.GA19150@localhost.localdomain>
References: <20170519155241.15817-1-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:37333 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756661AbdESUQM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 16:16:12 -0400
Received: by mail-wm0-f44.google.com with SMTP id d127so95527812wmf.0
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 13:16:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170519155241.15817-1-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 19, 2017 at 05:52:34PM +0200, Miroslav Lichvar wrote:
> Changes v5->v6:
> - fixed skb_is_swtx_tstamp() when OPT_TX_SWHW is disabled and improved
>   its description
> - improved OPT_PKTINFO documentation
> - improved scm_timestamping documentation

For the series:

Acked-by: Richard Cochran <richardcochran@gmail.com>
