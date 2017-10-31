From: Christoph Paasch <cpaasch@apple.com>
Subject: Re: [PATCH iproute2] ip: add fastopen_no_cookie option to ip route
Date: Tue, 31 Oct 2017 12:35:10 -0700
Message-ID: <20171031193510.GE44287@da0602a-dhcp105.apple.com>
References: <20171026181038.23929-1-cpaasch@apple.com>
 <20171027084003.6800a6c4@shemminger-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out2.apple.com ([17.151.62.25]:49376 "EHLO
        mail-in2.apple.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932583AbdJaTfK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 15:35:10 -0400
Content-disposition: inline
In-reply-to: <20171027084003.6800a6c4@shemminger-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Stephen,

On 27/10/17 - 08:40:03, Stephen Hemminger wrote:
> On Thu, 26 Oct 2017 11:10:38 -0700
> Christoph Paasch <cpaasch@apple.com> wrote:
> 
> > This patch adds fastopen_no_cookie option to enable/disable TCP fastopen
> > without a cookie on a per-route basis.
> > 
> > Support in Linux was added with 71c02379c762 (tcp: Configure TFO without
> > cookie per socket and/or per route).
> > 
> > Cc: Stephen Hemminger <stephen@networkplumber.org>
> > Signed-off-by: Christoph Paasch <cpaasch@apple.com>
> 
> Applied, thanks Christoph.

I see that this patch is not yet in your repo.

With the recent changes that went in, it also won't apply cleanly.

Do you want me to rebase & resubmit the patch?


Christoph
