From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 2/2] ip/vxlan: fix display of maxaddress option
Date: Sun, 28 Sep 2014 16:21:34 -0700
Message-ID: <20140928162134.5df2015a@urahara>
References: <1410274511-17709-1-git-send-email-nicolas.dichtel@6wind.com>
	<1410274511-17709-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:50666 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651AbaI1XVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 19:21:48 -0400
Received: by mail-pa0-f47.google.com with SMTP id rd3so5891932pab.20
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 16:21:48 -0700 (PDT)
In-Reply-To: <1410274511-17709-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  9 Sep 2014 16:55:11 +0200
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> Parenthesis are required else maxaddr value is a bool and thus output is always
> 1 when the option is set.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  ip/iplink_vxlan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 

Both patches applied
