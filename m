From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [[PATCH iproute2/net-next v2] 2/4] tc: flower: document SCTP
 ip_proto
Date: Sat, 3 Dec 2016 09:53:12 +0100
Message-ID: <20161203085311.GB10228@penelope.horms.nl>
References: <1480668321-20875-1-git-send-email-simon.horman@netronome.com>
 <1480668321-20875-3-git-send-email-simon.horman@netronome.com>
 <20161202150608.746eb843@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f181.google.com ([209.85.210.181]:34403 "EHLO
        mail-wj0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752580AbcLCIxQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 03:53:16 -0500
Received: by mail-wj0-f181.google.com with SMTP id mp19so250964706wjc.1
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 00:53:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161202150608.746eb843@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 02, 2016 at 03:06:08PM -0800, Stephen Hemminger wrote:
> On Fri,  2 Dec 2016 09:45:19 +0100
> Simon Horman <simon.horman@netronome.com> wrote:
> 
> > Add SCTP ip_proto to help text and man page.
> > 
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> 
> This doesn't apply cleanly to current net-next git.
> Probably some of the other man page changes caused reject.

Thanks, rebased and posted v3.
