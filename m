From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip: update the description of rp_filter in
 ip-sysctl.txt
Date: Wed, 02 Dec 2009 15:39:18 -0800 (PST)
Message-ID: <20091202.153918.04085201.davem@davemloft.net>
References: <4B14C000.3090608@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, rdunlap@xenotime.net
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42577
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755526AbZLBXjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 18:39:11 -0500
In-Reply-To: <4B14C000.3090608@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Tue, 01 Dec 2009 15:04:32 +0800

> The commit 27fed4175acf81ddd91d9a4ee2fd298981f60295
> （ip: fix logic of reverse path filter sysctl）has changed the logic of rp_filter.
> The document about rp_filter is out of date. Now, setting conf/all/rp_filte with 0 
> can also enable source validation.  
> 
> Update the document according to the commit.
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

Patch applied, thank you.
