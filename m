From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PATCH (TAKE 2)] [NET]: Use {htons,htonl,cpu_to_le16}()
 where appropriate.
Date: Tue, 06 Mar 2007 23:42:32 -0800 (PST)
Message-ID: <20070306.234232.58787816.davem@davemloft.net>
References: <20070307.145807.117077720.yoshfuji@linux-ipv6.org>
	<20070307.160821.77089513.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41833
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161288AbXCGHmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 02:42:33 -0500
In-Reply-To: <20070307.160821.77089513.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Wed, 07 Mar 2007 16:08:21 +0900 (JST)

> Dave,
> 
> In article <20070307.145807.117077720.yoshfuji@linux-ipv6.org> (at Wed, 07 Mar 2007 14:58:07 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:
> 
> > Please consider pulling following changesets from the
> > "net-2.6.22-20070307a-byteorder-20070307" branch at
> > <git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git>.
> 
> Argh, I found more places to convert in bluetooth.
> 
> I've made a new branch "net-2.6.22-20070307a-byteorder-20070307a" at
> <git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git>.

Pulled, thank you very much.

