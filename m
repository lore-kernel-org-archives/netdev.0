From: Bernd Eckenfels <ecki-news2002-04@lina.inka.de>
Subject: Re: Obtaining the ip address of an interface dynamically
Date: Tue, 30 Apr 2002 21:38:34 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <E172dSM-0003Y3-00@sites.inka.de>
References: <001401c1f066$cce6c210$0300a8c0@yellow>
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org
In-Reply-To: <001401c1f066$cce6c210$0300a8c0@yellow>
List-Id: netdev.vger.kernel.org

In article <001401c1f066$cce6c210$0300a8c0@yellow> you wrote:
> IPCon_GetIpAddrByStr sometimes, so I'm not sure.

You should look for errno/return value of ictl to be able to provide more
info where the problem is. 

BTW: you version leaks file descriptors.

