From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: adapt connect for repair move
Date: Thu, 22 Nov 2012 15:31:09 -0500 (EST)
Message-ID: <20121122.153109.5858248905090876.davem@davemloft.net>
References: <1353582838-18876-1-git-send-email-avagin@openvz.org>
	<50AE11BA.4030803@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avagin@openvz.org, netdev@vger.kernel.org, criu@openvz.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: xemul@parallels.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50AE11BA.4030803@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@parallels.com>
Date: Thu, 22 Nov 2012 15:51:22 +0400

> On 11/22/2012 03:13 PM, Andrey Vagin wrote:
>> This is work the same as for ipv4.
>> 
>> All other hacks about tcp repair are in common code for ipv4 and ipv6,
>> so this patch is enough for repairing ipv6 connections.
>> 
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
>> Cc: James Morris <jmorris@namei.org>
>> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
>> Cc: Patrick McHardy <kaber@trash.net>
>> Cc: Pavel Emelyanov <xemul@parallels.com>
>> Signed-off-by: Andrey Vagin <avagin@openvz.org>
> 
> Acked-by: Pavel Emelyanov <xemul@parallels.com>

Applied, thanks.
