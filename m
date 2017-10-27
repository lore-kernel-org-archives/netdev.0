From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip: add fastopen_no_cookie option to ip route
Date: Fri, 27 Oct 2017 08:40:03 +0200
Message-ID: <20171027084003.6800a6c4@shemminger-XPS-13-9360>
References: <20171026181038.23929-1-cpaasch@apple.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Christoph Paasch <cpaasch@apple.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:49909 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751072AbdJ0GkV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 02:40:21 -0400
Received: by mail-wm0-f42.google.com with SMTP id b189so1445732wmd.4
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 23:40:20 -0700 (PDT)
In-Reply-To: <20171026181038.23929-1-cpaasch@apple.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Oct 2017 11:10:38 -0700
Christoph Paasch <cpaasch@apple.com> wrote:

> This patch adds fastopen_no_cookie option to enable/disable TCP fastopen
> without a cookie on a per-route basis.
> 
> Support in Linux was added with 71c02379c762 (tcp: Configure TFO without
> cookie per socket and/or per route).
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Christoph Paasch <cpaasch@apple.com>

Applied, thanks Christoph.
