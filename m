From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 iproute2 1/2] utils: make hex2mem available to all
 users
Date: Sat, 18 Feb 2017 16:23:04 -0800
Message-ID: <20170218162304.732ab406@xeon-e3>
References: <1486725944-16898-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mrv@mojatatu.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35434 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750838AbdBSAX5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 19:23:57 -0500
Received: by mail-pf0-f172.google.com with SMTP id 68so10736921pfx.2
        for <netdev@vger.kernel.org>; Sat, 18 Feb 2017 16:23:12 -0800 (PST)
In-Reply-To: <1486725944-16898-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Feb 2017 06:25:43 -0500
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> hex2mem() api is useful for parsing hexstrings which are then packed in
> a stream of chars.
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

I went ahead and applied this part since it makes sense to have it now.
The other part depends on TC_ACT_COOKIE which is not upstream in net-next yet.
