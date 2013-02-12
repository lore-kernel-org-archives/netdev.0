From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: [net-next (TAKE 2) 0/4] IPv6 over Firewire
Date: Tue, 12 Feb 2013 20:46:04 +0100
Message-ID: <511A9BFC.9010907@gmail.com>
References: <5117620A.4050005@linux-ipv6.org> <51177689.4070904@gmail.com> <51177B15.3030405@linux-ipv6.org> <51179714.6010706@gmail.com> <5117B73C.10600@linux-ipv6.org> <5118C8B3.7080803@gmail.com> <5118EE78.5000508@linux-ipv6.org>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	davem@davemloft.net, stefanr@s5r6.in-berlin.de
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:40891 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933385Ab3BLTqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 14:46:09 -0500
Received: by mail-ee0-f45.google.com with SMTP id b57so241110eek.18
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 11:46:08 -0800 (PST)
In-Reply-To: <5118EE78.5000508@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Have you tried after skb->ip_summed = CHECKSUM_NONE change?
> 
> --yoshfuji

No, I' don't think so.

Nevertheless, there is some hope that I can try out your patch set
during this week and find some insight why IPv6 does not work with MacOS X.

Regards,

Stephan
