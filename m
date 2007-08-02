From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] SCTP: drop SACK if ctsn is not less than the next tsn
 of assoc
Date: Thu, 02 Aug 2007 10:40:28 -0400
Message-ID: <46B1ECDC.5000201@hp.com>
References: <18087.57737.908842.337891@zeus.sw.starentnetworks.com>		<46AEBE2B.1060702@cn.fujitsu.com>		<20070731113709.GA28333@hmsreliant.homelinux.net>	<1185902894.8234.5.camel@localhost.localdomain>	<46AFDC97.6080909@cn.fujitsu.com> <46AFFAB7.8050503@hp.com> <46B05EA9.4090507@cn.fujitsu.com> <46B08545.8030707@hp.com> <46B19C88.8070104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	lksctp-developers@lists.sourceforge.net,
	Sridhar Samudrala <sri@us.ibm.com>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:42040 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753502AbXHBOk5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 10:40:57 -0400
In-Reply-To: <46B19C88.8070104@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wei Yongjun wrote:
> Patch has been modified base on comment.
> Thanks.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> 

Ok, I've applied this patch, but in the future, please
generate patches so that they can be applied
with a -p1 flag.

Please see Documentation/SubmittingPatches for proper
format.

Thanks
-vlad
