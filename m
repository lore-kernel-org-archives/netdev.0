From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [net-next (TAKE 2) 0/4] IPv6 over Firewire
Date: Mon, 11 Feb 2013 22:13:28 +0900
Message-ID: <5118EE78.5000508@linux-ipv6.org>
References: <5117620A.4050005@linux-ipv6.org> <51177689.4070904@gmail.com> <51177B15.3030405@linux-ipv6.org> <51179714.6010706@gmail.com> <5117B73C.10600@linux-ipv6.org> <5118C8B3.7080803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	davem@davemloft.net, stefanr@s5r6.in-berlin.de,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:38656 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757086Ab3BKNNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 08:13:32 -0500
In-Reply-To: <5118C8B3.7080803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephan Gatzka wrote:
> Hi!
> 
>> Can I have you code?
> I meant the test patch I sent to the 1394 mailing list:
> 
> http://article.gmane.org/gmane.linux.kernel.firewire.devel/15900

Have you tried after skb->ip_summed = CHECKSUM_NONE change?

--yoshfuji
