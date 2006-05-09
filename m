From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]ip_options_fragment() has no effect on fragmentation
Date: Tue, 09 May 2006 15:20:24 -0700 (PDT)
Message-ID: <20060509.152024.12517857.davem@davemloft.net>
References: <1146875774.3659.22.camel@LINE>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:38578
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751229AbWEIWUd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 18:20:33 -0400
To: weiyj@soft.fujitsu.com
In-Reply-To: <1146875774.3659.22.camel@LINE>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <weiyj@soft.fujitsu.com>
Date: Fri, 05 May 2006 20:36:14 -0400

> I had tested the patch under linux system, maybe this mail is correct.
> 
> Fix error point to options in ip_options_fragment(). optptr get a error
> pointer to the ipv4 header, correct is pointer to ipv4 options.
> 
> Signed-off-by: Wei Yongjun <weiyj@soft.fujitsu.com>

Patch applied, thank you very much.
