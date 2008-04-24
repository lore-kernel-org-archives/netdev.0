From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RAW6: Do not allow set IPV6_CHECKSUM for ICMPv6 socket
Date: Thu, 24 Apr 2008 03:48:45 -0700 (PDT)
Message-ID: <20080424.034845.137470754.davem@davemloft.net>
References: <480B0A59.7000408@cn.fujitsu.com>
	<20080420.183835.02139171.yoshfuji@linux-ipv6.org>
	<dd9c5f130804200342r4bdc938fq4af15c9747ba6e06@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, wangchen@cn.fujitsu.com,
	netdev@vger.kernel.org
To: ellre923@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42723
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751373AbYDXKsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 06:48:45 -0400
In-Reply-To: <dd9c5f130804200342r4bdc938fq4af15c9747ba6e06@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "chen wang" <ellre923@gmail.com>
Date: Sun, 20 Apr 2008 18:42:14 +0800

> 2008/4/20, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>:
> > RFC3542 tells that IPV6_CHECKSUM socket option in the IPPROTO_IPV6
> 
> 
> 
>              ^^^^^^^^^^^^^^^^^^^
> Where in RFC3542 says that "only IPPROTO_IPV6 level" is not allowed to be
> set
> IPV6_CHECKSUM option on ICMPv6 socket?

Yoshifuji-san, please address this question.

I haven't applied this patch, and I won't until this is resolved
and discussed.
