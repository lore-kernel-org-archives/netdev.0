From: "H. Peter Anvin" <hpa@zytor.com>
Subject: IPv6: proxy_ndp to a network range
Date: Mon, 9 May 2016 01:06:51 -0700
Message-ID: <31ff66eb-38bd-0186-9e81-0543f0558323@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:54316 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751894AbcEIIG6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 04:06:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

There currently doesn't seem to be any support for proxy_ndp of a whole 
network mask, as IPv4 proxy_arp seems to permit.

a) Am I actually correct in this, or am I just missing something important?

b) Is there a technical reason for this, or is it just a limitation of 
the current implementation?

Thanks,

	-hpa
