From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: PROBLEM: oops in 2.6.21.1 after bringing up the network
Date: Sun, 29 Apr 2007 14:15:23 +0200
Message-ID: <6bffcb0e0704290515h51cf5064y7310203a84cecd73@mail.gmail.com>
References: <200704300000.25594.b.n.ryland@massey.ac.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Daniele Venzano" <venza@brownhat.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Brett Ryland" <nappers@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.228]:60297 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756434AbXD2MPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2007 08:15:24 -0400
Received: by nz-out-0506.google.com with SMTP id o1so1643574nzf
        for <netdev@vger.kernel.org>; Sun, 29 Apr 2007 05:15:24 -0700 (PDT)
In-Reply-To: <200704300000.25594.b.n.ryland@massey.ac.nz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Brett,

On 29/04/07, Brett Ryland <nappers@gmail.com> wrote:
> Hi,
> I am consistently getting a kernel oops from a vanilla 2.6.21.1 kernel. It
> also occurs in vanilla 2.6.21, but not in 2.6.20.8. The relevant section of
> the kernel is networking, in particular the sis900 module (I think).
> The attached file contains the oops and the information asked for on the site
> http://www.kernel.org/pub/linux/docs/lkml/reporting-bugs.html for reporting
> kernel oopses. The oops fully crashes my computer and leaves the capslock and
> numlock leds flashing, so the oops is transcribed by hand from a photo
> (hopefully I haven't made a mistake, I do still have the photo if it's
> needed).
>
> I'm not subscribed to the mailing list so please CC any questions/solutions to
> me.
>
> Regards,
> Nappers.
>
>

I added your report to known regressions
(http://kernelnewbies.org/known_regressions). Please send your .config
file.

Regards,
Michal

-- 
Michal K. K. Piotrowski
Kernel Monkeys
(http://kernel.wikidot.com/start)
