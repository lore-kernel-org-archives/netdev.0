From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] man: ip-route.8: Mention that lower metric means higher
 priority
Date: Tue, 27 Jun 2017 16:08:17 -0700
Message-ID: <20170627160817.6c1e41c7@xeon-e3>
References: <1498075185-19228-1-git-send-email-koomi@moshbit.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lukas Braun <koomi@moshbit.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:34552 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753892AbdF0XIY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 19:08:24 -0400
Received: by mail-pg0-f50.google.com with SMTP id t186so22587512pgb.1
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 16:08:24 -0700 (PDT)
In-Reply-To: <1498075185-19228-1-git-send-email-koomi@moshbit.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Jun 2017 21:59:45 +0200
Lukas Braun <koomi@moshbit.net> wrote:

> This is quite counter-intuitive when using the 'preference' keyword.
> 
> Signed-off-by: Lukas Braun <koomi@moshbit.net>

I think it goes back to some wording in RFC.
But your addition makes sense. Applied.
