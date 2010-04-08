From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: re-submit3 [ANNOUNCEMENT] NET: usb: sierra_net.c driver
Date: Wed, 07 Apr 2010 21:45:30 -0700 (PDT)
Message-ID: <20100407.214530.05341654.davem@davemloft.net>
References: <1270517948.14692.9.camel@Linuxdev4-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1270517948.14692.9.camel@Linuxdev4-laptop>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
Date: Mon, 5 Apr 2010 18:39:08 -0700

> Subject: re-submit3 [ANNOUNCEMENT] NET: usb: sierra_net.c driver
> From: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>

I want you to tell me exactly how you generated this patch.

It doesn't apply, and I suspect that you tried to fix the excess empty
lines at the end of certain files by editing the patch by hand.

If so, did you test the result?

The patch is corrupted and more importantly git won't accept it.

davem@sunset:~/src/GIT/net-2.6$ git am --signoff re-submit3-ANNOUNCEMENT-NET-usb-sierra_net.c-driver.patch 
Applying: re-submit3 [ANNOUNCEMENT] NET: usb: sierra_net.c driver
/home/davem/src/GIT/net-2.6/.git/rebase-apply/patch:36: new blank line at EOF.
+
error: drivers/net/usb/sierra_net.c: does not exist in index
Patch failed at 0001 re-submit3 [ANNOUNCEMENT] NET: usb: sierra_net.c driver
When you have resolved this problem run "git am --resolved".
If you would prefer to skip this patch, instead run "git am --skip".
To restore the original branch and stop patching run "git am --abort".
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
