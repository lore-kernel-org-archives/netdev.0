From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH 2/2] Update documented default values for various TCP/UDP
 tunables
Date: Tue, 05 Jul 2011 09:36:29 +0800
Message-ID: <4E126A9D.3060507@cn.fujitsu.com>
References: <20110704083616.43F2C8156C57@regina.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Max Matveev <makc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52358 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752350Ab1GEBfX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 21:35:23 -0400
In-Reply-To: <20110704083616.43F2C8156C57@regina.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Max Matveev wrote, at 06/22/2011 03:18 PM:
> tcp_rmem and tcp_wmem use 1 page as default value for the minimum
> amount of memory to be used, same as udp_wmem_min and udp_rmem_min.
> Pages are different size on different architectures - use the right
> units when describing the defaults.
> 
> Signed-off-by: Max Matveev <makc@redhat.com>

Reviewed-by: Shan Wei <shanwei@cn.fujitsu.com>


-- 
Best Regards
-----
Shan Wei
