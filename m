From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC iproute2/net-next 0/3] tc: flower: Support matching
 on ICMP
Date: Fri, 2 Dec 2016 18:52:42 +0100
Message-ID: <20161202175241.GB31495@penelope.horms.nl>
References: <1480672785-14570-1-git-send-email-simon.horman@netronome.com>
 <20161202171020.GD1883@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f178.google.com ([209.85.210.178]:34338 "EHLO
        mail-wj0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755590AbcLBRwp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 12:52:45 -0500
Received: by mail-wj0-f178.google.com with SMTP id mp19so238928625wjc.1
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 09:52:44 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161202171020.GD1883@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 02, 2016 at 06:10:20PM +0100, Jiri Pirko wrote:
> Fri, Dec 02, 2016 at 10:59:42AM CET, simon.horman@netronome.com wrote:
> >Add support for matching on ICMP type and code to flower. This is modeled
> >on existing support for matching on L4 ports.
> >
> >The second patch provided a minor cleanup which is in keeping with
> >they style used in the last patch.
> >
> >This is marked as an RFC to match the same designation given to the
> >corresponding kernel patches.
> 
> Looks nice, I only have those 2 enum nitpicks.

Thanks, I'll fix those and repost.
