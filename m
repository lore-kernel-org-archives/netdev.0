From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: add a fib_type to fib_info
Date: Thu, 04 Oct 2012 15:32:08 +0200
Message-ID: <1349357528.16011.55.camel@edumazet-glaptop>
References: <506955F3.8050304@googlemail.com>
	 <1349082950.12401.669.camel@edumazet-glaptop>
	 <20121001193434.GA14236@redhat.com>
	 <20121001.160115.1816241312626722150.davem@davemloft.net>
	 <1349121884.12401.721.camel@edumazet-glaptop>
	 <1349192133.12401.768.camel@edumazet-glaptop>
	 <1349192919.12401.778.camel@edumazet-glaptop>
	 <1349349926.16011.48.camel@edumazet-glaptop>
	 <506D8A4F.3020008@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gpiez@web.de, Dave Jones <davej@redhat.com>,
	Julian Anastasov <ja@ssi.bg>
To: Chris Clayton <chris2553@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:56285 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755020Ab2JDNcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 09:32:13 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so307755bkc.19
        for <netdev@vger.kernel.org>; Thu, 04 Oct 2012 06:32:12 -0700 (PDT)
In-Reply-To: <506D8A4F.3020008@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-04 at 14:08 +0100, Chris Clayton wrote:

> I've tested 3.6.0 with this patch applied and networking in a WinXP KVM 
> client is now working fine. The patch applies cleanly to 3.6.0, so I 
> assume the patch will be forwarded to stable in due course.
> 
> Tested-by: Chris Clayton <chris2553@googlemail.com>

Thanks for testing.
