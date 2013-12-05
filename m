From: Somnath Kotur <Somnath.Kotur@Emulex.Com>
Subject: RE: [PATCH net 0/3] be2net fixes
Date: Thu, 5 Dec 2013 06:24:10 +0000
Message-ID: <7F44EA5110810A40B7DAFB605C41975D2C96279B@CMEXMB1.ad.emulex.com>
References: <72e434bb-7c52-4dbe-a406-c6e0ad49e909@CMEXHTCAS2.ad.emulex.com>
	<20131205.001111.273727362951023546.davem@davemloft.net>
	<7F44EA5110810A40B7DAFB605C41975D2C96274B@CMEXMB1.ad.emulex.com>
 <20131205.003925.220601244226026270.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:51752 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246Ab3LEGYL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 01:24:11 -0500
In-Reply-To: <20131205.003925.220601244226026270.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This is absolutely not something an individual driver should decide to do,
> _EVERY_ driver has this issue.

OK, Understood, guess you want this to ideally be handled somewhere up in the stack/framework?

Meanwhile, I will  resend just the other 2 patches in the series , is that OK?

Thanks
Som
