From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Pull request for 'r8169-for-jeff-20070914' branch
Date: Tue, 18 Sep 2007 18:06:17 -0400
Message-ID: <46F04BD9.2000906@pobox.com>
References: <20070914204731.GA26189@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	David Gundersen <gundy@iinet.net.au>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43005 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750875AbXIRWGT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 18:06:19 -0400
In-Reply-To: <20070914204731.GA26189@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Please pull from branch 'r8169-for-jeff-20070914' in repository
> 
> git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git r8169-for-jeff-20070914
> 
> to get the fixes below.
> 
> Distance from 'netdev-2.6/upstream' (18d256761aa268fd2fb113c4fd26c400431f1dc1)
> ------------------------------------------------------------------------------
> 
> ec580a20c4bec3a011972a49cf5c20fc4502f9d1
> c8e51194b1979d08c43bc2f6cf6087cd3dd93fb6
> 
> Diffstat
> --------
> 
>  drivers/net/r8169.c |   14 +++++++++++++-
>  1 files changed, 13 insertions(+), 1 deletions(-)
> 
> Shortlog
> --------
> 
> Edward Hsu (1):
>       r8169: correct phy parameters for the 8110SC
> 
> Francois Romieu (1):
>       r8169: workaround against ignored TxPoll writes (8168)

but ACK the changes, of course


