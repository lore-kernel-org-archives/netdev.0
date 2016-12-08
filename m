From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next v6 0/2] net/sched: cls_flower: Support matching
 on ICMP
Date: Thu, 8 Dec 2016 22:43:05 +0200
Message-ID: <CAJ3xEMgBZu0utPE5goTz0V9j+_sFB69P2ziZeEh4oFuruzJYJw@mail.gmail.com>
References: <1481114908-24189-1-git-send-email-simon.horman@netronome.com> <20161208.115810.554381162900423199.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Simon Horman <simon.horman@netronome.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:36142 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753644AbcLHUnG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 15:43:06 -0500
Received: by mail-oi0-f67.google.com with SMTP id u15so51554936oie.3
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 12:43:06 -0800 (PST)
In-Reply-To: <20161208.115810.554381162900423199.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 8, 2016 at 6:58 PM, David Miller <davem@davemloft.net> wrote:

> Simon and Or, you both added extensions to cls_flower at the same
> time.  Or's changes went in first, so his UAPI numbers did not change.
> Simons, your changes went in next so your numbers did change and
> therefore you will have to recompile any userland components you were
> using for testing.

Yeah, I guess you had to do some rebasing there for Simon's series...
thanks for taking care
