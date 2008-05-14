From: David Miller <davem@davemloft.net>
Subject: Re: ip_finish_outpu2 question
Date: Wed, 14 May 2008 03:03:52 -0700 (PDT)
Message-ID: <20080514.030352.49295778.davem@davemloft.net>
References: <7aa53e090805132042k5476eaf6lb66e534232154bf5@mail.gmail.com>
	<20080513.213425.03637016.davem@davemloft.net>
	<416aa1ad0805140147m2efff9b1v6a5f8c3d0ee701c6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bshanth@gmail.com, netdev@vger.kernel.org
To: kalash.nainwal@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57958
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755986AbYENKD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 06:03:58 -0400
In-Reply-To: <416aa1ad0805140147m2efff9b1v6a5f8c3d0ee701c6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "kalash nainwal" <kalash.nainwal@gmail.com>
Date: Wed, 14 May 2008 14:17:58 +0530

> I thought memcpy in linux is anyway always alignment safe. no?

Yes, but an aligned copy is faster.
