From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] ipv6 addrconf: Fix addrconf_ifid_eui64 of 802.15.4 devices
Date: Fri, 08 Mar 2013 11:21:38 +0900
Message-ID: <51394B32.9090807@linux-ipv6.org>
References: <1362687183-3425-1-git-send-email-alex.aring@gmail.com> <20130307204120.GA3808@x61s.8.8.8.8>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:40199 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933164Ab3CHCVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 21:21:40 -0500
In-Reply-To: <20130307204120.GA3808@x61s.8.8.8.8>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Alexander Aring wrote:
> Hi,
> 
> I don't know if this is a right solution for that, because other
> functions like addrconf_ifid_infiniband to manipulate eui after memcpy,
> too.
> 
> But this patch solves my problems with ieee802154 stack.

What kind of problems do you have?

--yoshfuji
