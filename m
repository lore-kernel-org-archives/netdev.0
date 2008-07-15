From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: v4 [PATCH 9/9] 8021q: Check return of dev_set_promiscuity/allmulti
Date: Tue, 15 Jul 2008 14:04:47 +0800
Message-ID: <487C3DFF.1050809@cn.fujitsu.com>
References: <487C0ABA.1070506@cn.fujitsu.com>	<487C12A5.8010505@cn.fujitsu.com> <20080714.210056.47426171.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52106 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753025AbYGOGJw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2008 02:09:52 -0400
In-Reply-To: <20080714.210056.47426171.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-7-15 12:00:
> But I had to apply this one also by hand, as it conflicted with
> Patrick's GVRP changes already in the tree.
> 

Sorry*2 for making you typing my patch twice. ;)

> When you are maintaining a patch set like this, you have to update
> your tree and regenerate your patches in order to make sure no new
> conflicts exist before submitting your patches.
> 
> That part isn't my job :)
> 
> Thanks.

OK.
But I need some help from you, otherwise the latest tree to me is Linus's
mainline tree.
Actually, long time ago, I want to git-clone your net tree but failed.
But I can git-clone Linus's.
The reason is that in my working place I can only use http protocol when git
clone. But your tree seems not work for http git-clone.
I asked Herbert before, he said, maybe git-update-server-info needs to be
executed.
I am very appreciated if you can figure out why net tree can't be cloned by http.
And maybe there are some other people whose employer's firewall filtering git
port.
Thank you for your understanding in advance :)

