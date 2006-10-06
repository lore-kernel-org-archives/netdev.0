From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 02/02] net/ipv6: seperate sit driver to extra module
 (addrconf.c changes)
Date: Fri, 06 Oct 2006 22:00:45 +0900 (JST)
Message-ID: <20061006.220045.89792760.yoshfuji@linux-ipv6.org>
References: <20061006093927.GB12460@zlug.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:49935 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932072AbWJFM6V
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Oct 2006 08:58:21 -0400
To: joro-lkml@zlug.org
In-Reply-To: <20061006093927.GB12460@zlug.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20061006093927.GB12460@zlug.org> (at Fri, 6 Oct 2006 11:39:27 +0200), Joerg Roedel <joro-lkml@zlug.org> says:

> This patch contains the changes to net/ipv6/addrconf.c to remove sit
> specific code if the sit driver is not selected.
> 
> Signed-off-by: Joerg Roedel <joro-lkml@zlug.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
