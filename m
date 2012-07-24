From: hayeswang <hayeswang@realtek.com>
Subject: RE: [RFC] r8169 : why SG / TX checksum are default disabled
Date: Tue, 24 Jul 2012 14:34:04 +0800
Message-ID: <CEE7FFC13FF3495C9771B87B8F199BA7@realtek.com.tw>
References: <20120718.132840.1571938255177607234.davem@davemloft.net> <20120718214422.GA18207@electric-eye.fr.zoreil.com> <1342649136.2626.3757.camel@edumazet-glaptop> <20120718.152405.1083396282134539674.davem@davemloft.net> <EF06A7B3C1E6432BB660CDEF8E1D2A1B@realtek.com.tw> <20120720100846.GA17398@electric-eye.fr.zoreil.com> <A4FD513AF09D40849B8A75C371F1D431@realtek.com.tw> <20120720210107.GA28118@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: 'David Miller' <davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:41282 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752846Ab2GXGeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 02:34:18 -0400
In-Reply-To: <20120720210107.GA28118@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Saturday, July 21, 2012 5:01 AM
> To: Hayeswang
> Cc: 'David Miller'; eric.dumazet@gmail.com; netdev@vger.kernel.org
> Subject: Re: [RFC] r8169 : why SG / TX checksum are default disabled
> 
[...]
> 
> Btw, would there be any point in setting the TcpHeaderOffset field for
> the post-8168c chipsets ?

It is used to tell the haredware where the TCP header starts from. I think it is
reserved for ipv6.
 
Best Regards,
Hayes
