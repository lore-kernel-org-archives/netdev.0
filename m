From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [IPV6] RAW: Add checksum default defines for
 mobility header.
Date: Tue, 05 Dec 2006 13:49:18 -0800 (PST)
Message-ID: <20061205.134918.94889883.davem@davemloft.net>
References: <11653130071739-git-send-email-nakam@linux-ipv6.org>
	<20061205.200242.01826773.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nakam@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40642
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759182AbWLEVtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 16:49:12 -0500
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20061205.200242.01826773.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 05 Dec 2006 20:02:42 +0900 (JST)

> In article <11653130071739-git-send-email-nakam@linux-ipv6.org> (at Tue,  5 Dec 2006 19:03:27 +0900), Masahide NAKAMURA <nakam@linux-ipv6.org> says:
> 
> > Add checksum default defines for mobility header(MH).
> > As the result kernel's behavior is to handle MH checksum
> > as default.
> 
> I'd like to hold this on.  I need to check RFC.

Ok.
