From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/2] [IPV6] RAW: Add checksum default defines for
 mobility header.
Date: Tue, 05 Dec 2006 20:02:42 +0900 (JST)
Message-ID: <20061205.200242.01826773.yoshfuji@linux-ipv6.org>
References: <11653130071739-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:39253 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759940AbWLELCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 06:02:30 -0500
To: davem@davemloft.net, nakam@linux-ipv6.org
In-Reply-To: <11653130071739-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <11653130071739-git-send-email-nakam@linux-ipv6.org> (at Tue,  5 Dec 2006 19:03:27 +0900), Masahide NAKAMURA <nakam@linux-ipv6.org> says:

> Add checksum default defines for mobility header(MH).
> As the result kernel's behavior is to handle MH checksum
> as default.

I'd like to hold this on.  I need to check RFC.

--yoshfuji
