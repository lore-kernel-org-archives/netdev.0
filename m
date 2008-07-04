From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/2] Pull request for 'r8169-next' branch
Date: Fri, 04 Jul 2008 08:36:53 -0400
Message-ID: <486E1965.30909@garzik.org>
References: <20080629131739.GA31201@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60177 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753331AbYGDMg6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 08:36:58 -0400
In-Reply-To: <20080629131739.GA31201@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> Please pull from branch 'r8169-next' in repository
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git r8169-next
> 
> to get the changes below.
> 
> Distance from 'davem-next' (be0976be9148f31ee0d1997354c3e30ff8d07587)
> ---------------------------------------------------------------------
> 
> 865c652d6be9929927cabdc54b137b7541eb6612
> 1087f4f4af302e6e2fa40dd741f306444d90bece
> 
> Diffstat
> --------
> 
>  drivers/net/Kconfig |   16 +-----
>  drivers/net/r8169.c |  145 +++++++++++++++-----------------------------------
>  2 files changed, 45 insertions(+), 116 deletions(-)
> 
> Shortlog
> --------
> 
> Francois Romieu (2):
>       r8169: multicast register update (sync with Realtek's 8.004.00 8168 driver)
>       r8169: remove non-napi code

pulled


