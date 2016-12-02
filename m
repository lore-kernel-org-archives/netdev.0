From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC net-next 0/2] net/sched: cls_flower: Support matching
 on ICMP
Date: Fri, 2 Dec 2016 18:52:21 +0100
Message-ID: <20161202175220.GA31495@penelope.horms.nl>
References: <1480672352-13291-1-git-send-email-simon.horman@netronome.com>
 <20161202171048.GE1883@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S.  Miller" <davem@davemloft.net>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36621 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755323AbcLBRwc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 12:52:32 -0500
Received: by mail-wm0-f47.google.com with SMTP id g23so24080704wme.1
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 09:52:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161202171048.GE1883@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 02, 2016 at 06:10:48PM +0100, Jiri Pirko wrote:
> Fri, Dec 02, 2016 at 10:52:30AM CET, simon.horman@netronome.com wrote:
> >Hi,
> >
> >this series add supports for matching on ICMP type and code to cls_flower.
> >This is modeled on existing support for matching on L4 ports. The updates
> >to the dissector are intended to allow for code and storage re-use.
> 
> Looks fine to me. Thanks!

Thanks, I'll drop the RFC designation and repost.
