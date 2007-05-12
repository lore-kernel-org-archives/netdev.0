From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Pull request for 'r8169-for-jeff' branch
Date: Sat, 12 May 2007 10:24:44 +0200
Message-ID: <20070512082444.GA16774@electric-eye.fr.zoreil.com>
References: <20070508110354.GA16917@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	edward_hsu@realtek.com.tw
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39401 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754877AbXELI05 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 May 2007 04:26:57 -0400
Content-Disposition: inline
In-Reply-To: <20070508110354.GA16917@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> :
> Please pull from branch 'r8169-for-jeff' in repository
> 
> git://electric-eye.fr.zoreil.com/home/romieu/linux/linux-2.6-out r8169-for-jeff
[...]
> Shortlog
> --------
> 
> Francois Romieu (10):
>       r8169: add per-device hw_start handler (1/2)
>       r8169: add per-device hw_start handler (2/2)
>       r8169: merge with version 6.001.00 of Realtek's r8169 driver
>       r8169: merge with version 8.001.00 of Realtek's r8168 driver
>       r8169: confusion between hardware and IP header alignment
>       r8169: small 8101 comment
>       r8169: remove the media option
>       r8169: cleanup
>       r8169: add bit description for the TxPoll register
>       r8169: align the IP header when there is no DMA constraint
> 
> I removed the MSI stuff and the MAC address change support from the
> previous serie. They will be submitted again after updating and testing.

Do you schedule to include any r8169 change in 2.6.22 and should I rebase
against latest linus/upstream ?

-- 
Ueimor
