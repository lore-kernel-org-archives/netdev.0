From: David Miller <davem@davemloft.net>
Subject: Re: [patch v2] sctp: cleanup: remove duplicate assignment
Date: Tue, 27 Apr 2010 09:58:23 -0700 (PDT)
Message-ID: <20100427.095823.98890165.davem@davemloft.net>
References: <4BD1AE9D.6090807@hp.com>
	<20100424171805.GO29093@bicker>
	<4BD6F582.9030804@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, sri@us.ibm.com, yjwei@cn.fujitsu.com,
	cdischino@sonusnet.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52202
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752527Ab0D0Q6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 12:58:17 -0400
In-Reply-To: <4BD6F582.9030804@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Tue, 27 Apr 2010 10:32:34 -0400

> 
> 
> Dan Carpenter wrote:
>> This assignment isn't needed because we did it earlier already.
>> 
>> Also another reason to delete the assignment is because it triggers a
>> Smatch warning about checking for NULL pointers after a dereference.
>> 
>> Reported-by: Vlad Yasevich <vladislav.yasevich@hp.com>
>> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> Thanks.  I'll take this one.

And when will I get this from you? :-)
