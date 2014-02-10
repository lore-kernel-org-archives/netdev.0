From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 0/3] Support for tcp-metrics source address
Date: Mon, 10 Feb 2014 14:47:13 -0800
Message-ID: <20140210144713.46d3e0d3@nehalam.linuxnetplumber.net>
References: <1391724904-30504-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:62816 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400AbaBJWrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 17:47:16 -0500
Received: by mail-pb0-f49.google.com with SMTP id up15so6840658pbc.22
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 14:47:16 -0800 (PST)
In-Reply-To: <1391724904-30504-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  6 Feb 2014 23:15:01 +0100
Christoph Paasch <christoph.paasch@uclouvain.be> wrote:

> This patchset implements support for showing and deleting tcp-metrics
> based on the source-address.
> 
> Christoph Paasch (3):
>   tcp_metrics: Rename addr to daddr and add local variable
>   tcp_metrics: Display source-address
>   tcp_metrics: Allow removal based on the source-IP
> 
>  include/linux/tcp_metrics.h |   2 +
>  ip/tcp_metrics.c            | 154 +++++++++++++++++++++++++++++++-------------
>  2 files changed, 111 insertions(+), 45 deletions(-)
> 

Applied
