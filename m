From: Beniamino Galvani <bgalvani@redhat.com>
Subject: Re: BUG in free_netdev() on ppp link deletion
Date: Fri, 6 Oct 2017 10:09:03 +0200
Message-ID: <20171006080902.GA11223@tp>
References: <20171003074413.GA26158@tp>
 <20171003164003.f5yay2oe6dhxnump@alphalink.fr>
 <20171005145503.ehv34hkzm5gtrjcp@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-ppp@vger.kernel.org, netdev@vger.kernel.org,
        Paul Mackerras <paulus@samba.org>,
        David Ahern <dsahern@gmail.com>,
        Gao Feng <gfree.wind@vip.163.com>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58992 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750815AbdJFIJI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 04:09:08 -0400
Content-Disposition: inline
In-Reply-To: <20171005145503.ehv34hkzm5gtrjcp@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 05, 2017 at 04:55:03PM +0200, Guillaume Nault wrote:
> Sorry for the delay, I've followed a few complicated dead ends before
> getting to this simple and rather obvious fix.
> 
> Can you try this patch?
> 
> [..]

The patch solves the issue, thanks.

Beniamino
