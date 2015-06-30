From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFC] 2/2 huawei_cdc_ncm: introduce new TX ncm stack
Date: Tue, 30 Jun 2015 09:45:02 +0200 (CEST)
Message-ID: <alpine.LNX.2.20.1506300941540.4401@localhost.localdomain>
References: <1435012335-6055-1-git-send-email-mrkiko.rs@gmail.com> <1435012335-6055-3-git-send-email-mrkiko.rs@gmail.com> <1435225769.28594.13.camel@suse.com> <alpine.LNX.2.20.1506251327570.25021@localhost.localdomain> <1435239526.28594.24.camel@suse.de>
 <alpine.LNX.2.20.1506251543240.16582@localhost.localdomain> <1435306442.2914.8.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1435306442.2914.8.camel-IBi9RG/b67k@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ok, for now I should let go of this - might be it was a little bit too much for 
the time constaints I am having.
But thank you for your effort Oliver.
Anyway, trying to write this new TX engine helped me in understand better 
things and conceive the patch I sent you affecting cdc_ncm.c, which triggers 
some OOPSes but not in a qemu vm, so I can't read them actually.

Any hint on my code is always apreciated, regardless.
Enrico
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
