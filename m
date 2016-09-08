From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv2 iproute2 net-next] nstat: add sctp snmp support
Date: Thu, 8 Sep 2016 14:30:19 -0700
Message-ID: <20160908143019.6f7765e1@xeon-e3>
References: <1473046502-5395-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:32807 "EHLO
        mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751792AbcIHVaJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 17:30:09 -0400
Received: by mail-pa0-f50.google.com with SMTP id cm16so21059579pac.0
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 14:30:09 -0700 (PDT)
In-Reply-To: <1473046502-5395-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  5 Sep 2016 11:35:02 +0800
Hangbin Liu <liuhangbin@gmail.com> wrote:

> SCTP module was not load by default. But this should be OK since we will not
> load table if fdopen() failed, also opening the proc file won't load SCTP
> kernel module.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>

Applied thanks.
