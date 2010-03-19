From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen: The driver doesn't work on NX_P3_B1 so cause
 probe to fail.
Date: Thu, 18 Mar 2010 22:21:26 -0700 (PDT)
Message-ID: <20100318.222126.27823381.davem@davemloft.net>
References: <m1y6hqdol4.fsf@fess.ebiederm.org>
	<99737F4847ED0A48AECC9F4A1974A4B80CFEFED04B@MNEXMB2.qlogic.org>
	<m11vfic6d0.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amit.salecha@qlogic.com, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39365
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751198Ab0CSFVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 01:21:04 -0400
In-Reply-To: <m11vfic6d0.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 18 Mar 2010 02:43:39 -0700

> Amit Salecha <amit.salecha@qlogic.com> writes:
> 
>> Sorry for all the problem you faced.
>>
>> But you shouldn't add support of device which is not supported.
>> Netxen is now owned by Qlogic. You should first contact Qlogic to solve your problem.
>> Qlogic will take needed action based on problem.
> 
> I'm not adding support.  I am sending a patch removing support for cards
> that do not work with the current driver and have not worked since 2.6.31.

You qlogic folks better resolve this _FAST_ or else I'll
make an executive decision about how to handle this and
I guarentee I'll make a decision that you will not like.

Thanks. :-)
