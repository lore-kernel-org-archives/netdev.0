From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'upstream-fixes' branch of wireless-2.6
Date: Fri, 10 Nov 2006 11:11:18 -0500
Message-ID: <4554A4A6.1060306@garzik.org>
References: <20061108045825.GA15272@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:22148 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1946730AbWKJQLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 11:11:22 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061108045825.GA15272@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> The following changes since commit edd106fc8ac1826dbe231b70ce0762db24133e5c:
>   Auke Kok:
>         e1000: Fix regression: garbled stats and irq allocation during swsusp
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-fixes
> 
> Adrian Bunk:
>       bcm43xx: Add error checking in bcm43xx_sprom_write()
> 
> Michael Buesch:
>       bcm43xx: Drain TX status before starting IRQs
> 
>  drivers/net/wireless/bcm43xx/bcm43xx_main.c |   22 ++++++++++++++++++++--
>  1 files changed, 20 insertions(+), 2 deletions(-)

pulled


