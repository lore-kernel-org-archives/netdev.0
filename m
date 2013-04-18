From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] vxlan: add ipv6 support
Date: Thu, 18 Apr 2013 15:55:08 -0700
Message-ID: <20130418155508.010c7c09@nehalam.linuxnetplumber.net>
References: <1366175423-27310-1-git-send-email-amwang@redhat.com>
	<1366175423-27310-7-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:59446 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753496Ab3DRWzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 18:55:39 -0400
Received: by mail-pa0-f54.google.com with SMTP id fa11so1883069pad.13
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 15:55:39 -0700 (PDT)
In-Reply-To: <1366175423-27310-7-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 Apr 2013 13:10:23 +0800
Cong Wang <amwang@redhat.com> wrote:

> From: Cong Wang <amwang@redhat.com>
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
>  include/linux/if_link.h |    2 ++
>  ip/iplink_vxlan.c       |   45 ++++++++++++++++++++++++++++++++++++++-------
>  2 files changed, 40 insertions(+), 7 deletions(-)
> 

Resubmit after net-next is merged to upstream.
