From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v2 0/5] switchdev: avoid duplicate packet
 forwarding
Date: Thu, 16 Jul 2015 18:33:57 +0900
Message-ID: <20150716093355.GA13462@penelope.isobedori.kobe.vergenet.net>
References: <1437033897-8050-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@resnulli.us, roopa@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:32907 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753922AbbGPJeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 05:34:08 -0400
Received: by padck2 with SMTP id ck2so39876538pad.0
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 02:34:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1437033897-8050-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 16, 2015 at 01:04:52AM -0700, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>

[snip]

> Scott Feldman (5):
>   net: don't reforward packets already forwarded by offload device
>   net: add phys ID compare helper to test if two IDs are the same
>   switchdev: add offload_fwd_mark generator helper
>   rocker: add offload_fwd_mark support
>   switchdev: update documentation for offload_fwd_mark

[snip]

All patches:
Reviewed-by: Simon Horman <simon.horman@netronome.com>
