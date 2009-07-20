From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: zero features for a vlan over bond / vlan features
Date: Mon, 20 Jul 2009 11:08:32 +0300
Message-ID: <4A642600.2010501@voltaire.com>
References: <24949.1240530461@death.nxdomain.ibm.com> <4A2CDB16.9030000@Voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:41414 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752689AbZGTIIr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jul 2009 04:08:47 -0400
In-Reply-To: <4A2CDB16.9030000@Voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz wrote:
> Jay, I have tested with your patch and indeed now, vlan-over-bond (e.g bond0.4001) advertises features to the stack wheres before it didn't. Below is the patch you sent with the debugging prints removed and my signature added, I would be happy if you set the change-log && your signature and push it further to Dave. I'm also find if you prefer that I'll do that.
>
> Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>
>   
Hi Jay,

This (http://marc.info/?l=linux-netdev&m=124445367820790) is pending 
quite a lot of time and already missed 2.6.31, please let me know if you 
prefer that I will push it directly to Dave, or you want to do so, thanks

Or.


