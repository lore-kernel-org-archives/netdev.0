From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH net-next-2.6 v6 1/5] sctp: Add Auto-ASCONF support
Date: Tue, 26 Apr 2011 13:30:13 +0800
Message-ID: <4DB65865.8040201@cn.fujitsu.com>
References: <5D4D424A-5545-44C4-909A-4DDE594BD5D4@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Michio Honda <micchie@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:65005 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752531Ab1DZFa2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2011 01:30:28 -0400
In-Reply-To: <5D4D424A-5545-44C4-909A-4DDE594BD5D4@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> SCTP reconfigure the IP addresses in the association by using ASCONF chunks as mentioned in RFC5061.  
> For example, we can start to use the newly configured IP address in the existing association.  
> ASCONF operation is invoked in two ways: 
> First is done by the application to call sctp_bindx() system call.  
> Second is automatic operation in the SCTP stack with address events in the host computer (called auto_asconf) .  
> The former is already implemented, and this patch implement the latter.  
>
> Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
>

Acked-by: Wei Yongjun <yjwei@cn.fujitsu.com>

