From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next 0/2] ip: Allow TTL propagation to/from
 IP packets to be configured
Date: Wed, 12 Apr 2017 10:00:28 -0700
Message-ID: <20170412100028.22db144a@xeon-e3>
References: <1491834972-26668-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35284 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753947AbdDLRAb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 13:00:31 -0400
Received: by mail-pf0-f170.google.com with SMTP id i5so16490364pfc.2
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 10:00:30 -0700 (PDT)
In-Reply-To: <1491834972-26668-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Apr 2017 15:36:10 +0100
Robert Shearman <rshearma@brocade.com> wrote:

> This patch series adds support for per-MPLS-lightweight-tunnel ttl
> values and per route ttl-propagation for the purposes of MPLS to be
> specified.
> 
> Robert Shearman (2):
>   iproute: Add support for ttl-propagation attribute
>   iproute: Add support for MPLS LWT ttl attribute
> 
>  ip/iproute.c           | 22 ++++++++++++++++++++++
>  ip/iproute_lwtunnel.c  | 31 +++++++++++++++++++++++++++++--
>  man/man8/ip-route.8.in | 19 +++++++++++++++++--
>  3 files changed, 68 insertions(+), 4 deletions(-)
> 

Both applied, thanks
