From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip: add fastopen_no_cookie option to ip route
Date: Tue, 31 Oct 2017 22:20:27 +0100
Message-ID: <20171031222027.5a3458dd@shemminger-XPS-13-9360>
References: <20171026181038.23929-1-cpaasch@apple.com>
        <20171027084003.6800a6c4@shemminger-XPS-13-9360>
        <20171031193510.GE44287@da0602a-dhcp105.apple.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Christoph Paasch <cpaasch@apple.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:48257 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751641AbdJaVUw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 17:20:52 -0400
Received: by mail-lf0-f67.google.com with SMTP id a69so398975lfe.5
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 14:20:52 -0700 (PDT)
In-Reply-To: <20171031193510.GE44287@da0602a-dhcp105.apple.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Oct 2017 12:35:10 -0700
Christoph Paasch <cpaasch@apple.com> wrote:

> Hello Stephen,
> 
> On 27/10/17 - 08:40:03, Stephen Hemminger wrote:
> > On Thu, 26 Oct 2017 11:10:38 -0700
> > Christoph Paasch <cpaasch@apple.com> wrote:
> >   
> > > This patch adds fastopen_no_cookie option to enable/disable TCP fastopen
> > > without a cookie on a per-route basis.
> > > 
> > > Support in Linux was added with 71c02379c762 (tcp: Configure TFO without
> > > cookie per socket and/or per route).
> > > 
> > > Cc: Stephen Hemminger <stephen@networkplumber.org>
> > > Signed-off-by: Christoph Paasch <cpaasch@apple.com>  
> > 
> > Applied, thanks Christoph.  
> 
> I see that this patch is not yet in your repo.
> 
> With the recent changes that went in, it also won't apply cleanly.
> 
> Do you want me to rebase & resubmit the patch?
> 
> 
> Christoph

Not sure where it got lost. Please resubmit against net-next branch
