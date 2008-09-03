From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/6] Pull request for 'r8169-fixes' branch
Date: Wed, 03 Sep 2008 10:22:54 -0400
Message-ID: <48BE9DBE.4060302@garzik.org>
References: <20080817162330.GA18690@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>,
	Ivan Vecera <ivecera@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38915 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753724AbYICOW7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 10:22:59 -0400
In-Reply-To: <20080817162330.GA18690@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> Please pull from branch 'r8169-fixes' in repository
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git r8169-fixes
> 
> to get the changes below.
> 
> Distance from 'upstream-davem' (d6f8aa8586dabe605454f3c98a5c1a577c3e0cfb)
> -------------------------------------------------------------------------
> 
> 2857ffb7b8913ef713533ac5783abd70a20529e4
> dacf815434a4d5f5b45687873df46927c64cfb19
> f162a5d1b326d54b0be7e3100f69763d8a707721
> 9c14ceafa5ca7f57225a43fb0785c56ddc7f1823
> 458a9f617adfb2fc5f38e7673339115c4ba3290f
> ccdffb9a88b2907b159538d7bfd6256621db4f84
> 
> Diffstat
> --------
> 
>  drivers/net/r8169.c |  401 ++++++++++++++++++++++++++++++++++++++++++---------
>  1 files changed, 335 insertions(+), 66 deletions(-)
> 
> Shortlog
> --------
> 
> Francois Romieu (6):
>       r8169: get ethtool settings through the generic mii helper
>       r8169: Tx performance tweak helper
>       r8169: use pci_find_capability for the PCI-E features
>       r8169: add 8168/8101 registers description
>       r8169: add hw start helpers for the 8168 and the 8101
>       r8169: additional 8101 and 8102 support

pulled into net-next


