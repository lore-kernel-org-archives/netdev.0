From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Subject: [RFC/PATCH 0/3] UDP memory usage accounting (take 3)
Date: Tue, 02 Oct 2007 22:09:32 +0900
Message-ID: <4702430C.2080002@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	=?windows-1252?Q?=3F=3F_=3F=3F?= <yoshfuji@linux-ipv6.org>,
	Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>,
	=?windows-1252?Q?=22=3F=3F=40RedHat=22?= <haoki@redhat.com>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.hitachi.co.jp ([133.145.228.42]:43060 "EHLO
	mail7.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751684AbXJBNJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 09:09:39 -0400
Received: from mlsv18.hitachi.co.jp (unknown [133.144.234.166])
	by mail7.hitachi.co.jp (Postfix) with ESMTP id 1CB4237AD5
	for <netdev@vger.kernel.org>; Tue,  2 Oct 2007 22:09:38 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set try to introduce memory usage accounting for 
UDP(currently ipv4 only).

This is the second post of take 2 patch, because previous
post was broken by my MUA setting.

Only what I chage is my MUA setting. There is no code
change from take 2.

This patch set is for 2.6.23-rc8.

I appreciate your comment/test/feedback.

Satoshi Oshima
