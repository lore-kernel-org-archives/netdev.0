From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix Default to 'y' for SR9800 Device Driver, setting
 to 'n'
Date: Thu, 13 Feb 2014 18:42:21 -0500 (EST)
Message-ID: <20140213.184221.1712626655601756449.davem@davemloft.net>
References: <1392265339-14841-1-git-send-email-liujunliang_ljl@163.com>
	<20140213.183237.1108958546198981160.davem@davemloft.net>
	<52FD6579.5070104@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: liujunliang_ljl@163.com, thierry.reding@gmail.com,
	horms@verge.net.au, joe@perches.com, romieu@fr.zoreil.com,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	sunhecheng@vip.126.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52FD6579.5070104@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 14 Feb 2014 03:38:17 +0300

> Hello.
> 
> On 02/14/2014 02:32 AM, David Miller wrote:
> 
>>> From: Liu Junliang <liujunliang_ljl@163.com>
> 
>>> Signed-off-by: Liu Junliang <liujunliang_ljl@163.com>
> 
>> I think it's more canonical to specify no default at all.
> 
>    That's what he did, no?

Indeed, my bad, patch applied, thanks!
