From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH 1/2] usbnet: Delete an error message for a failed memory
 allocation in usbnet_write_cmd_async()
Date: Mon, 22 May 2017 09:08:10 +0200
Message-ID: <1495436890.11462.0.camel@suse.com>
References: <a81c2551-ce6c-967d-1120-4307f95b1e65@users.sourceforge.net>
         <3b831fce-93ed-c017-2549-967a39c2d1da@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46463 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751137AbdEVHJs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 03:09:48 -0400
In-Reply-To: <3b831fce-93ed-c017-2549-967a39c2d1da@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, den 22.05.2017, 07:09 +0200 schrieb SF Markus Elfring:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Mon, 22 May 2017 06:33:48 +0200
> 
> Omit an extra message for a memory allocation failure in this function.
> 
> This issue was detected by using the Coccinelle software.
> 
> Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-Refactor_Strings-WSang_0.pdf
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
Acked-by: Oliver Neukum <oneukum@suse.com>
