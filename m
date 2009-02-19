From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCH 00/12]Next:Get rid of all the old micro DMA_XXBIT_MASK and
 use DMA_BIT_MASK(n) instead
Date: Thu, 19 Feb 2009 14:35:52 +0800
Message-ID: <499CFDC8.1070600@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Borislav Petkov <petkovbb@googlemail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59631 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751796AbZBSGe3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 01:34:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace all DMA_XXBIT_MASK micro with new DMA_BIT_MASK(n) micro

01:Replace all DMA_64BIT_MASK micro with DMA_BIT_MASK(64)
02:Replace all DMA_48BIT_MASK micro with DMA_BIT_MASK(48)
03:Replace all DMA_40BIT_MASK micro with DMA_BIT_MASK(40)
04:Replace all DMA_39BIT_MASK micro with DMA_BIT_MASK(39)
05:Replace all DMA_35BIT_MASK micro with DMA_BIT_MASK(35)
06:Replace all DMA_32BIT_MASK micro with DMA_BIT_MASK(32)
07:Replace all DMA_31BIT_MASK micro with DMA_BIT_MASK(31)
08:Replace all DMA_30BIT_MASK micro with DMA_BIT_MASK(30)
09:Replace all DMA_28BIT_MASK micro with DMA_BIT_MASK(28)
10:Replace all DMA_24BIT_MASK micro with DMA_BIT_MASK(24)
11:Remove defines of DMA_XXBIT_MASK micro
12:Update related documentations


-- 
Regards
Yang Hongyang



