From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCHv2 net] net/flow: fix fc->percpu NULL pointer dereference
Date: Sun, 11 Jun 2017 09:39:35 +0800
Message-ID: <20170611013935.GE12974@leo.usersys.redhat.com>
References: <1496996036-22077-1-git-send-email-liuhangbin@gmail.com>
 <1497013755-24481-1-git-send-email-liuhangbin@gmail.com>
 <CADvbK_dBuJKymP6tT358EEN2Qg6s+f8Sj8z-UN6ypdoDNcp-dA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33039 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751634AbdFKBjq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 21:39:46 -0400
Received: by mail-pf0-f170.google.com with SMTP id 83so40117270pfr.0
        for <netdev@vger.kernel.org>; Sat, 10 Jun 2017 18:39:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CADvbK_dBuJKymP6tT358EEN2Qg6s+f8Sj8z-UN6ypdoDNcp-dA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 10, 2017 at 04:29:23PM +0800, Xin Long wrote:
>  It's a xfrm fix, pls also fix the title, like:
>    xfrm: move xfrm_garbage_collect out of xfrm_policy_flush
> or
>    xfrm: fix ...
Opps, sorry forgot that.
