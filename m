From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Announce] LARTC wiki available
Date: Sat, 02 Jun 2012 17:50:31 +0200
Message-ID: <1338652231.2760.1706.camel@edumazet-glaptop>
References: <4EFB3B2B.7060200@linuxsystems.it>
	 <4FC8F0E4.6060102@linuxsystems.it>
	 <8063b8e35d17fd072cbdc9908cf12519@njm.linuxwall.info>
	 <4FCA2545.60702@ukfsn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julien Vehent <julien@linuxwall.info>,
	=?ISO-8859-1?Q?Niccol=F2?= Belli <darkbasic@linuxsystems.it>,
	lartc@vger.kernel.org, netfilter@vger.kernel.org,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Andy Furniss <andyqos@ukfsn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44311 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758119Ab2FBPuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2012 11:50:40 -0400
In-Reply-To: <4FCA2545.60702@ukfsn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-06-02 at 15:37 +0100, Andy Furniss wrote:

> 
> Anyway it seems that early this year SFQ got some love and now has 
> several more options (red, headdrop, limit >127, depth as param) - so as 
> long as your iproute/kernel is current have a look at man tc-sfq for 
> details.

Yes, but fq_codel is really better than SFQ.
