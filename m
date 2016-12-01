From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: iproute2 public git outdated?
Date: Thu, 1 Dec 2016 22:39:10 +0200
Message-ID: <CAKoUArnPVZchErJN9k6E5f80QvYWfj-JRBO_RNx34M4ZekpAZg@mail.gmail.com>
References: <20161201121806.GA21576@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Phil Sutter <phil@nwl.cc>, Netdev <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:35981 "EHLO
        mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759751AbcLAUjM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 15:39:12 -0500
Received: by mail-io0-f171.google.com with SMTP id m5so308141358ioe.3
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 12:39:11 -0800 (PST)
In-Reply-To: <20161201121806.GA21576@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Phil,
I suggest that you will try again now, it seems that the iproute2 git
repo was updated in the last 2-4 hours, and "git log" in master shows
now a patch from 30 of November (actually it is your "Add notes about
dropped IPv4 route cache" patch)

Regards,
Rami Rosen


On 1 December 2016 at 14:18, Phil Sutter <phil@nwl.cc> wrote:
> Hi,
>
> I am using iproute2's public git repo at this URL:
>
> git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git
>
> To my surprise, neither master nor net-next branches have received new
> commits since end of October. Did the repo location change or was it
> just not updated for a while?
>
> Thanks, Phil
