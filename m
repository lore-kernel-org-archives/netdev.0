From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] tcp_output: Re: rare bad TCP checksum with 2.6.19?
Date: Mon, 22 Jan 2007 14:46:54 +0100
Message-ID: <45B4C04E.4070405@trash.net>
References: <45AE2EDF.4060709@tls.msk.ru> <20070119110641.GA3135@ff.dom.local> <20070119211027.GA16626@gondor.apana.org.au> <20070122065214.GA1634@ff.dom.local> <20070122074557.GA15461@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>, Michael Tokarev <mjt@tls.msk.ru>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62922 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751731AbXAVNq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jan 2007 08:46:58 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20070122074557.GA15461@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Mon, Jan 22, 2007 at 07:52:14AM +0100, Jarek Poplawski wrote:
> 
>> 
>>I was so impressed by the amount of work done by Michael
>>that I magnified his merit and forgot to mention the role
>>of Patrick and Herbert, particularly here:
> 
> 
> You don't need to be so modest!
> 
> While no doubt Patrick helped in tracking this down, my role in
> this thread is solely in adding this bug in the first place :)


Actually I only meditated over the code without figuring out
anything useful, but thanks anyway :)

