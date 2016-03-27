From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 master 0/2] setting flow label support
Date: Sun, 27 Mar 2016 11:00:05 -0700
Message-ID: <20160327110005.544fccd9@xeon-e3>
References: <cover.1458833866.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34447 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752659AbcC0R7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2016 13:59:50 -0400
Received: by mail-pa0-f51.google.com with SMTP id fe3so81536465pab.1
        for <netdev@vger.kernel.org>; Sun, 27 Mar 2016 10:59:50 -0700 (PDT)
In-Reply-To: <cover.1458833866.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Mar 2016 16:49:54 +0100
Daniel Borkmann <daniel@iogearbox.net> wrote:

> On top of Jesse's csum patches for vxlan, geneve:
> 
>   - http://patchwork.ozlabs.org/patch/599746/
>   - http://patchwork.ozlabs.org/patch/599747/
> 
> Thanks!
> 
> Daniel Borkmann (2):
>   vxlan: add support to set flow label
>   geneve: add support to set flow label
> 
>  ip/ip_common.h        |  4 ++++
>  ip/iplink_geneve.c    | 29 ++++++++++++++++++++++++-----
>  ip/iplink_vxlan.c     | 29 ++++++++++++++++++++++++-----
>  man/man8/ip-link.8.in | 12 ++++++++++++
>  4 files changed, 64 insertions(+), 10 deletions(-)
> 

Applied thanks
