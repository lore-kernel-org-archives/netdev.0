From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next 0/8] net: Checksum offload changes - Part VI
Date: Thu, 28 Aug 2014 08:36:19 -0700
Message-ID: <20140828153618.GA12855@its-macbook-pro.westell.com>
References: <alpine.DEB.2.02.1408272114490.505@tomh.mtv.corp.google.com>
 <20140827.225626.704750789701421634.davem@davemloft.net>
 <CA+mtBx-7jTpa31zcSOShsqamuu1XgzgKJKmo6ip=AxC+-Ucy9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:52433 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823AbaH1Pga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 11:36:30 -0400
Received: by mail-pa0-f54.google.com with SMTP id fb1so3013851pad.27
        for <netdev@vger.kernel.org>; Thu, 28 Aug 2014 08:36:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CA+mtBx-7jTpa31zcSOShsqamuu1XgzgKJKmo6ip=AxC+-Ucy9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 28, 2014 at 07:26:55AM -0700, Tom Herbert wrote:
> On Wed, Aug 27, 2014 at 10:56 PM, David Miller <davem@davemloft.net> wrote:
> > From: Tom Herbert <therbert@google.com>
> > Date: Wed, 27 Aug 2014 21:26:27 -0700 (PDT)
> >
> >> I am working on overhauling RX checksum offload. Goals of this effort
> >> are:
> >
> > Hmmm, what's happening with this series?  Some patches I got 2 copies
> > of, some I didn't see at all.
> 
> I believe they all finally made it. Configuration of SMTP server
> changed beneath me, and it looks they were able to figure how to
> forward all the mail after seven hours... :-(

Tom,

in the future could you send them as a single thread the way
git send-mail does? Right now your patches are always scattered all
over my mailbox which makes it harder to review.
This mailserver issue only underlined the problem.

Thanks
