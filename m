From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next v2 0/2] Add support for seg6 l2encap
 mode
Date: Wed, 30 Aug 2017 08:30:13 -0700
Message-ID: <20170830083013.6bbac80f@xeon-e3>
References: <20170828192640.19240-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:37776 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751409AbdH3PaR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 11:30:17 -0400
Received: by mail-pg0-f41.google.com with SMTP id 83so20761583pgb.4
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 08:30:17 -0700 (PDT)
In-Reply-To: <20170828192640.19240-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Aug 2017 20:26:38 +0100
David Lebrun <david.lebrun@uclouvain.be> wrote:

> This patch series adds support for the new L2ENCAP mode for SRv6
> encapsulations.
> 
> v2: use a name/value table for encap modes
> 
> David Lebrun (2):
>   iproute: add support for seg6 l2encap mode
>   man: add documentation for seg6 l2encap mode
> 
>  ip/iproute_lwtunnel.c  | 41 ++++++++++++++++++++++++++++++-----------
>  man/man8/ip-route.8.in |  6 +++++-
>  2 files changed, 35 insertions(+), 12 deletions(-)
> 

Applied to net-next
