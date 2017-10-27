From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 00/15] tcp: move 14 sysctls to namespaces
Date: Thu, 26 Oct 2017 21:54:42 -0700
Message-ID: <1509080082.11887.34.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171026233526.6155-1-edumazet@google.com>
         <20171027.134618.1897786547133417592.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:56391 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750790AbdJ0Eyp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 00:54:45 -0400
Received: by mail-io0-f179.google.com with SMTP id m81so10101617ioi.13
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 21:54:44 -0700 (PDT)
In-Reply-To: <20171027.134618.1897786547133417592.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-10-27 at 13:46 +0900, David Miller wrote:
> From: Eric Dumazet <edumazet@google.com>
> Date: Thu, 26 Oct 2017 16:35:11 -0700
> 
> > Ideally all TCP sysctls should be per netns.
> > This patch series takes care of 14 of sysctls.
> > More to come later.
> 
> The tcp-fack patch doesn't apply cleanly, please respin.
> 
> Thank you.

Sure, I did a git rebase that went well.

v2 is coming right away, thanks.
