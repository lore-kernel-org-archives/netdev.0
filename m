From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Sat, 21 Oct 2006 14:22:21 -0400
Message-ID: <453A655D.2030407@garzik.org>
References: <20061017213412.GD32614@tuxdriver.com> <20061017213557.GE32614@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36844 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1766623AbWJUSWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2006 14:22:23 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061017213557.GE32614@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> The following changes since commit 41072a1be57f63bf83afc31c44d72de018d800fa:
>   John W. Linville:
>         zd1211rw: fix build-break caused by association race fix
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream
> 
> Alexey Dobriyan:
>       prism54: use BUILD_BUG_ON
> 
> Daniel Drake:
>       zd1211rw: Add 3 more device IDs
>       ieee80211: Move IV/ICV stripping into ieee80211_rx
> 
> Dmitry Torokhov:
>       atmel: save on array initialization
>       atmel: use ARRAY_SIZE()
>       atmel: whitespace cleanup
>       prism54: fix potential race in reset scheduling
>       prism54: whitespace cleanup
> 
> Holden Karau:
>       atmel: output signal strength information
> 
> Larry Finger:
>       bcm43xx: output proper link quality with scans
>       ieee80211: Drop and count duplicate data frames to remove 'replay detected' log messages
> 
> matthieu castet:
>       ieee80211: allow mtu bigger than 1500
> 
> Stefano Brivio:
>       bcm43xx: add PCI-E code

pulled

