From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: Re: [PATCH 1/2] macvtap: update file current position
Date: Fri, 6 Dec 2013 09:52:07 +0800
Message-ID: <CAEH94LjUYzH=pOeQoqF0AsUrN309B8i5zo5Jh_YRf1XTDsQf+Q@mail.gmail.com>
References: <1386149341-10485-1-git-send-email-zwu.kernel@gmail.com>
	<20131205.204411.86525521936068436.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org,
	linux-kernel mlist <linux-kernel@vger.kernel.org>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:59497 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753392Ab3LFBwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 20:52:08 -0500
In-Reply-To: <20131205.204411.86525521936068436.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 6, 2013 at 9:44 AM, David Miller <davem@davemloft.net> wrote:
> From: Zhi Yong Wu <zwu.kernel@gmail.com>
> Date: Wed,  4 Dec 2013 17:29:00 +0800
>
>> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>>
>> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>
> The tun driver seems to have the same exact bug, please if you are going
> to fix one then fix the other too.
will post v2 with tun bugfix.
>
> Thanks.



-- 
Regards,

Zhi Yong Wu
