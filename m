From: Tomasz Chmielewski <mangoo@wpkg.org>
Subject: Re: [PATCH iproute2] vxlan: allow specifying multiple default
 destinations
Date: Mon, 19 Sep 2016 02:41:33 +0900
Message-ID: <1023cd04dedcd828db3d19865b61772b@admin.virtall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.virtall.com ([178.63.195.102]:40917 "EHLO mail.virtall.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756777AbcIRRv3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Sep 2016 13:51:29 -0400
Received: from localhost (localhost [127.0.0.1])
        by mailext.virtall.com (Postfix) with ESMTP id 37EE825BEB7
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 19:41:34 +0200 (CEST)
Received: from mailext.virtall.com ([127.0.0.1])
        by localhost (web1.virtall.com [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id QyNsXS_FYuAw for <netdev@vger.kernel.org>;
        Sun, 18 Sep 2016 19:41:33 +0200 (CEST)
Received: from admin.virtall.com (localhost [127.0.0.1])
        by mailext.virtall.com (Postfix) with ESMTP
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 19:41:33 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
> ---
> This patch depends on the pending changes to ip/iplink_vxlan.c as as
> well as on IPv6 support in vxlan. I'll rebase and resend it once all
> the changes to vxlan are merged.

Was this one (and related) ever merged?

Full thread here:

http://marc.info/?t=136688790500006&r=1&w=4



Tomasz Chmielewski
https://lxadm.com
