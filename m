From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: RE: [PATCH net-next 00/11] FUJITSU Extended Socket driver version
 1.1
Date: Tue, 12 Apr 2016 08:35:09 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A734EF16E@G01JPEXMBYT01>
References: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <20160411.115617.2124648532876219571.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm04.jp.fujitsu.com ([202.219.69.171]:30710 "EHLO
	mgwkm04.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756044AbcDLIfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 04:35:20 -0400
Received: from g01jpfmpwyt02.exch.g01.fujitsu.local (g01jpfmpwyt02.exch.g01.fujitsu.local [10.128.193.56])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id AF6DDAC01D3
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 17:35:11 +0900 (JST)
In-Reply-To: <20160411.115617.2124648532876219571.davem@davemloft.net>
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David and Jiri,

  Thank you for reviewing!

> This submission is of an extremely low quality.
> 
> All of your ioctl additions are completely inappropriate, as are your
> debugfs facilities.  You must remove all of them completely.

 OK, I'll remove ioctl part. But I'd like to keep some debugfs facility
 for status information and some specific stats other thatn net_stats.

 Are you okay with this ?

 Sincerely,
 Taku Izumi
