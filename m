From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: arp: code cleanup
Date: Wed, 01 Sep 2010 18:33:27 -0700 (PDT)
Message-ID: <20100901.183327.171496192.davem@davemloft.net>
References: <1283385110-2953-1-git-send-email-xiaosuo@gmail.com>
	<20100901.175712.199039832.davem@davemloft.net>
	<AANLkTik1VFj_8G+G9bH+MvbUyNpSUmDfJUQF+-VCjeKu@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36773
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754180Ab0IBBdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 21:33:11 -0400
In-Reply-To: <AANLkTik1VFj_8G+G9bH+MvbUyNpSUmDfJUQF+-VCjeKu@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Thu, 2 Sep 2010 09:28:13 +0800

> Do you mean that all the multi-line comments should be written as you
> said above or I should not touch any comment? Thanks.

Let us start slowly and try your patch without the comment changes,
then we can work on comments in a seperate patch if you like.

Thanks.
