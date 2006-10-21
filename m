From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'upstream-fixes' branch of wireless-2.6
Date: Sat, 21 Oct 2006 14:22:37 -0400
Message-ID: <453A656D.7090706@garzik.org>
References: <20061017213412.GD32614@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39404 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1766642AbWJUSWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2006 14:22:39 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061017213412.GD32614@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> The following changes since commit 51018b0a3160d253283173c2f54f16746cee5852:
>   Ulrich Drepper:
>         make UML compile (FC6/x86-64)
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-fixes
> 
> Dave Kleikamp:
>       airo: check if need to freeze
> 
> Eric Sesterhenn:
>       zd1201: Possible NULL dereference
> 
> Florin Malita:
>       airo.c: check returned values
> 
> Jean Tourrilhes:
>       orinoco: fix WE-21 buffer overflow
>       wireless: More WE-21 potential overflows...
> 
> John W. Linville:
>       zd1211rw: fix build-break caused by association race fix
> 
> Larry Finger:
>       bcm43xx-softmac: check returned value from pci_enable_device
>       bcm43xx-softmac: Fix system hang for x86-64 with >1GB RAM
> 
> Laurent Riffard:
>       sotftmac: fix a slab corruption in WEP restricted key association
> 
> Michael Buesch:
>       bcm43xx: fix race condition in periodic work handler
>       softmac: Fix WX and association related races

pulled


