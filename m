From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2 1/3] iproute2: arpd: use ll_addr_a2n and
 ll_addr_n2a
Date: Thu, 15 May 2014 08:43:42 -0700
Message-ID: <20140515084342.1aaae42a@nehalam.linuxnetplumber.net>
References: <1400159422-11797-1-git-send-email-jiri@resnulli.us>
	<1400159422-11797-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mschmidt@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:46253 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751764AbaEOPnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 11:43:46 -0400
Received: by mail-pb0-f45.google.com with SMTP id um1so1257553pbc.32
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 08:43:46 -0700 (PDT)
In-Reply-To: <1400159422-11797-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 May 2014 15:10:20 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  misc/arpd.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 

Why not use more standard ether_ntoa ?
