From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH/RFC net] ipv6: fix fragmentation bug
Date: Mon, 4 Nov 2013 10:43:04 +0100
Message-ID: <20131104094303.GA20131@omega>
References: <1383557174-19424-1-git-send-email-alex.aring@gmail.com>
 <1383557174-19424-2-git-send-email-alex.aring@gmail.com>
 <52776B5A.6030701@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:57975 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488Ab3KDJnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 04:43:11 -0500
Received: by mail-ee0-f43.google.com with SMTP id b47so975750eek.30
        for <netdev@vger.kernel.org>; Mon, 04 Nov 2013 01:43:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <52776B5A.6030701@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Nov 04, 2013 at 05:39:38PM +0800, Fan Du wrote:
> Hi, Alexander
> 
> I don't know whether which head commit you are sitting, this issue might has already been fixed by Steffen:
> https://git.kernel.org/cgit/linux/kernel/git/klassert/ipsec.git/commit/?id=84502b5ef9849a9694673b15c31bd3ac693010ae
> 
> 
oh I am using current net-next which haven't this fix.

Thanks
