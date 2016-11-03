From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH] net/sched: cls_flower: Support matching on SCTP ports
Date: Thu, 3 Nov 2016 13:28:06 +0100
Message-ID: <20161103122752.GB16169@penelope.isobedori.kobe.vergenet.net>
References: <1478175862-28642-1-git-send-email-simon.horman@netronome.com>
 <1478175862-28642-2-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37512 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754507AbcKCM2W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 08:28:22 -0400
Received: by mail-wm0-f43.google.com with SMTP id t79so97548488wmt.0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 05:28:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1478175862-28642-2-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 03, 2016 at 01:24:22PM +0100, Simon Horman wrote:
> Support matching on SCTP ports in the same way that matching
> on TCP and UDP ports is already supported.

Sorry for this duplicate, I was having network troubles and it
seems to have suck out somehow.
