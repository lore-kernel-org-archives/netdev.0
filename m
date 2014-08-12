From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lec: Fix bug introduced by
 b67bfe0d42cac56c512dd5da4b1b347a23f4b70a
Date: Tue, 12 Aug 2014 15:02:36 -0700 (PDT)
Message-ID: <20140812.150236.769942550923694604.davem@davemloft.net>
References: <201408121224.s7CCOKCk008781@thirdoffive.cmf.nrl.navy.mil>
	<53EA09DC.5070909@cogentembedded.com>
	<20140812090036.5e4530ad@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39446 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899AbaHLWCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 18:02:37 -0400
In-Reply-To: <20140812090036.5e4530ad@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Date: Tue, 12 Aug 2014 09:00:36 -0400

> b67bfe0d42cac56c512dd5da4b1b347a23f4b70a (hlist: drop the node
> parameter from iterators) dropped the node parameter from
> iterators which lec_tbl_walk() was using to iterate the list.
> 
> Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

Applied.
