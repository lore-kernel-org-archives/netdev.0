From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [git patches] net driver fixes
Date: Sun, 31 Jul 2005 16:50:30 -0700 (PDT)
Message-ID: <Pine.LNX.4.58.0507311649460.14342@g5.osdl.org>
References: <42ED5F30.2080907@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>,
	Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262131AbVGaXup@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <42ED5F30.2080907@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sun, 31 Jul 2005, Jeff Garzik wrote:
>
> Please pull from the 'upstream-fixes' branch of
> rsync://rsync.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
> 
> to obtain the fixes described in the attached diffstat/changelog/patch.

Could you please try to edit the emails you apply to something prettier 
than this:


    [PATCH] Fix OMAP specific typo in smc91x.h

    --ReaqsoxgOBHFXBhH
    Content-Type: text/plain; charset=us-ascii
    Content-Disposition: inline

    Hi Jeff,

    Here's a little patch fixing a typo in smc91x.h.

    Regards,

    Tony

    --ReaqsoxgOBHFXBhH
    Content-Type: text/x-chdr; charset=us-ascii
    Content-Disposition: inline; filename="patch-fix-typo-smc91x.h"
    Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

Ugh. It's not like we want people saying "Hi there" in our changelogs.

		Linus
