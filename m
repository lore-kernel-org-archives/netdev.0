From: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Subject: Re: [PATCH] ftrace: change the export format of trace_kfree_skb()
Date: Tue, 09 Jun 2009 08:57:19 +0800
Message-ID: <4A2DB36F.1040406@cn.fujitsu.com>
References: <4A2CD77F.7080609@cn.fujitsu.com> <20090608102508.GA4304@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, mingo@elte.hu
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50814 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753095AbZFIA4z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jun 2009 20:56:55 -0400
In-Reply-To: <20090608102508.GA4304@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Neil Horman wrote:
> 
> No objection to the code change, but whats with the new mode?  Why are you
> making the file executable?
> 

Hi Neil:

Thanks for your review, this is my mistake, I'll fix it in v2 patch.

Thanks,
Xiao Guangrong

> Neil
> 
> 
> 
