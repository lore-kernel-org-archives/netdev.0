From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v2 0/2] Covscan: Shell script fixes
Date: Fri, 18 Aug 2017 09:12:07 -0700
Message-ID: <20170818091207.40bd4887@xeon-e3>
References: <20170817170932.24900-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:36147 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750987AbdHRQMP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 12:12:15 -0400
Received: by mail-pg0-f52.google.com with SMTP id i12so67251560pgr.3
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 09:12:15 -0700 (PDT)
In-Reply-To: <20170817170932.24900-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Aug 2017 19:09:30 +0200
Phil Sutter <phil@nwl.cc> wrote:

> This series collects patches from v1 which deal with programming
> mistakes in shell scripts.
> 
> No changes to the actual patches, just splitting into smaller series.
> 
> Phil Sutter (2):
>   examples: Some shell fixes to cbq.init
>   ifcfg: Quote left-hand side of [ ] expression
> 
>  examples/cbq.init-v0.7.3 | 24 ++++++++++++------------
>  ip/ifcfg                 |  2 +-
>  2 files changed, 13 insertions(+), 13 deletions(-)
> 

Applied.
