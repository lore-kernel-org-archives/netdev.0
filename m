From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net: ipv6: Add IPv6 support to the ping socket.
Date: Wed, 15 May 2013 00:47:41 +0000 (UTC)
Message-ID: <kmulvd$q8k$1@ger.gmane.org>
References: <20130514145804.3780F180460@drone2.tok.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:38345 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758644Ab3EOAsA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 May 2013 20:48:00 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UcPss-0001Io-L6
	for netdev@vger.kernel.org; Wed, 15 May 2013 02:47:58 +0200
Received: from 182.246.98.80 ([182.246.98.80])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 02:47:58 +0200
Received: from xiyou.wangcong by 182.246.98.80 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 02:47:58 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 May 2013 at 14:58 GMT, Lorenzo Colitti <lorenzo@google.com> wrote:
> This adds the ability to send ICMPv6 echo requests without a
> raw socket. The equivalent ability for ICMPv4 was added in
> 2011.
>

This should target for net-next, rather than net.
