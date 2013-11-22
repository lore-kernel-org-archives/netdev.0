From: wangweidong <wangweidong1@huawei.com>
Subject: Re: [PATCH] tipc: fix a lockdep warning
Date: Fri, 22 Nov 2013 16:47:11 +0800
Message-ID: <528F1A0F.50505@huawei.com>
References: <528F136E.1030506@huawei.com> <528F1745.4050202@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <dingtianhong@huawei.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>,
	Erik Hugne <erik.hugne@ericsson.com>
To: Ying Xue <ying.xue@windriver.com>, <jon.maloy@ericsson.com>,
	<allan.stephens@windriver.com>, <davem@davemloft.net>,
	"Paul.Gortmaker@windriver.com" <Paul.Gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:28867 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751497Ab3KVIsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 03:48:15 -0500
In-Reply-To: <528F1745.4050202@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/11/22 16:35, Ying Xue wrote:
> Hi Weidong,
> 
> I know you ever posted below patch into netdev mail list last month. And
> at that moment I also told you we already had one better solution to fix
> the issue. However, after our TIPC internal development team went
> through a long and bitter dispute about that "better" solution, we
> eventually made a consensus by proposing below approach to fix your met
> issue:
> 
> http://thread.gmane.org/gmane.network.tipc.general/4926/
> 
> I think the patchset should be ready now.
> 

Sorry for that fogot what you had told me. And I will look at the patchset.
it looks nice.
Thanks. 

> Sorry for your inconvenience.
> 
> Regards,
> Ying
> 
> 
