From: Willy Tarreau <w@1wt.eu>
Subject: Re: on kernel 2.6.34.15, vlan and raw packets can not be received with gfar-enet nic
Date: Thu, 3 Apr 2014 12:21:36 +0200
Message-ID: <20140403102136.GF16158@1wt.eu>
References: <53310F4E.4080104@gmail.com> <533D25D4.4000607@gmail.com> <20140403092727.GD16158@1wt.eu> <533D34BD.900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sandeep.kumar@freescale.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, "Tao, Yue" <Yue.Tao@windriver.com>,
	"Yang, Zhangle (Eric)" <Zhangle.Yang@windriver.com>,
	guang.yang@windriver.com, joe@perches.com, festevam@gmail.com,
	linuxppc-dev@lists.ozlabs.org, richardcochran@gmail.com,
	clarocq@gmail.com, yongjun_wei@trendmicro.com.cn,
	Claudiu Manoil <claudiu.manoil@freescale.com>
To: zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2896 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751848AbaDCKVt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Apr 2014 06:21:49 -0400
Content-Disposition: inline
In-Reply-To: <533D34BD.900@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 03, 2014 at 06:15:25PM +0800, zhuyj wrote:
> Hi, Willy
> 
> I made a new patch. In long commit message, I inserted the equivalent 
> mainline commit
> about this feature. Maybe it is better. Now this patch is in the 
> attachment. Please check
> and merge it into kernel 2.6.32.62.

Sure, it's much better this way.

Thanks!
Willy
