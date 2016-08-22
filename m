From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip: report IFLA_GSO_MAX_SIZE and
 IFLA_GSO_MAX_SEGS
Date: Mon, 22 Aug 2016 10:04:39 -0700
Message-ID: <20160822100439.2a98a25e@xeon-e3>
References: <1471469961.29842.42.camel@edumazet-glaptop3.roam.corp.google.com>
        <20160818145251.784f11d5@xeon-e3>
        <1471558478.29842.91.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36276 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755484AbcHVRE0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 13:04:26 -0400
Received: by mail-pf0-f170.google.com with SMTP id h186so34103231pfg.3
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 10:04:26 -0700 (PDT)
In-Reply-To: <1471558478.29842.91.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Aug 2016 15:14:38 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Thu, 2016-08-18 at 14:52 -0700, Stephen Hemminger wrote:
> > On Wed, 17 Aug 2016 14:39:21 -0700
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >   
> > > From: Eric Dumazet <edumazet@google.com>
> > > 
> > > kernel support for these attributes was added in linux-4.6
> > > 
> > > Signed-off-by: Eric Dumazet <edumazet@google.com>  
> > 
> > 
> > What about setting them?  
> 
> This is not something the kernel does at this moment.
> 
> Drivers usually set a value, depending on hardware or software
> constraints.
> 
> 
> 

Ok, applied.
