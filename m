From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [RFC net-next] net: Build IPv6 into kernel by default
Date: Mon, 13 Jul 2015 15:53:43 +0900
Message-ID: <55A36077.5020703@miraclelinux.com>
References: <1436474549-491618-1-git-send-email-tom@herbertland.com> <20150710.225709.1099075922833429830.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, netdev@vger.kernel.org,
	kernel-team@fb.com
To: David Miller <davem@davemloft.net>, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33449 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbbGMGxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 02:53:46 -0400
Received: by padck2 with SMTP id ck2so37670624pad.0
        for <netdev@vger.kernel.org>; Sun, 12 Jul 2015 23:53:46 -0700 (PDT)
In-Reply-To: <20150710.225709.1099075922833429830.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

David Miller wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Thu, 9 Jul 2015 13:42:29 -0700
> 
>> This patch makes the default to build IPv6 into the kernel. IPv6
>> now has significant traction and any remaining vestiges of IPv6
>> not being provided parity with IPv4 should be swept away. IPv6 is now
>> core to the Internet and kernel.
> 
> I guess I'm fine with this, just fix up the doc error Dave Jones
> pointed out.

I am deeply moved.

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
