From: Hangbin Liu <haliu@redhat.com>
Subject: Re: [PATCHv4 iproute2 2/2] lib/libnetlink: update rtnl_talk to
 support malloc buff at run time
Date: Wed, 25 Oct 2017 21:16:12 +0800
Message-ID: <20171025131612.GN29971@leo.usersys.redhat.com>
References: <1506605626-1744-1-git-send-email-haliu@redhat.com>
 <1506605626-1744-3-git-send-email-haliu@redhat.com>
 <20171025124556.14df7d15@shemminger-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Michal Kubecek <mkubecek@suse.cz>,
        Phil Sutter <phil@nwl.cc>, Hangbin Liu <liuhangbin@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59784 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751036AbdJYNQS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Oct 2017 09:16:18 -0400
Content-Disposition: inline
In-Reply-To: <20171025124556.14df7d15@shemminger-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 25, 2017 at 12:45:56PM +0200, Stephen Hemminger wrote:
> This does not apply cleanly to net-next branch
> 
> Applying: lib/libnetlink: update rtnl_talk to support malloc buff at run time
> error: patch failed: ip/ipl2tp.c:185
> error: ip/ipl2tp.c: patch does not apply
> error: patch failed: ip/iplink.c:1023
> error: ip/iplink.c: patch does not apply
> Patch failed at 0002 lib/libnetlink: update rtnl_talk to support malloc buff at run time
> 
Oh, I will send a new version patch based on latest net-next code ASAP.

Thanks
Hangbin
