From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Pull request for 'r6040' branch
Date: Sat, 01 Dec 2007 16:57:56 -0500
Message-ID: <4751D8E4.1020006@garzik.org>
References: <20071127204536.61bf7921.akpm@google.com> <20071127230601.fbb60024.akpm@linux-foundation.org> <20071128220812.GA12598@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Sten Wang <sten.wang@rdc.com.tw>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45665 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751400AbXLAV6C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 16:58:02 -0500
In-Reply-To: <20071128220812.GA12598@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> Please pull from branch 'r6040' in repository
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git r6040
> 
> to get the changes below.
> 
> Distance from 'netdev-2.6-upstream' (02e063b58b7c7084bae3d599c54dcf26c8efa9b7)
> ------------------------------------------------------------------------------
> 
> 8dd657d2d82657c1d70219a704ccfe4fecfc55be
> f00c12227fe587b6c1bbb6b459394db29dc5fac0
> c7eaa9bde00c778b53f778d49617353d3b9b0c21
> cc27eeb9474a87b2073488f37d9e90e6a3557664
> 
> Diffstat
> --------
> 
>  drivers/net/r6040.c     |  138 ++++++++++++++++++++++-------------------------
>  include/linux/pci_ids.h |    1 -
>  2 files changed, 64 insertions(+), 75 deletions(-)
> 
> Shortlog
> --------
> 
> Francois Romieu (4):
>       r6040: compile error
>       r6040: remove virt_to_bus
>       r6040: erroneous dev->priv
>       r6040: cleanups

changes pulled, thanks for helping to clean this up!


