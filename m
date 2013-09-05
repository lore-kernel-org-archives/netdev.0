From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add missing braces to do_tcp_setsockopt
Date: Thu, 05 Sep 2013 14:18:52 -0400 (EDT)
Message-ID: <20130905.141852.1374954208870969275.davem@davemloft.net>
References: <20130905174333.GA3021@redhat.com>
	<CADVnQy=_pXCdJH_qVyz6MOr-2Qo3FahYK4itThmaa2YKJm2PgA@mail.gmail.com>
	<20130905175847.GB5682@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, netdev@vger.kernel.org, ycheng@google.com
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37510 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391Ab3IESSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 14:18:54 -0400
In-Reply-To: <20130905175847.GB5682@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Thu, 5 Sep 2013 13:58:47 -0400

> On Thu, Sep 05, 2013 at 01:55:48PM -0400, Neal Cardwell wrote:
>  > On Thu, Sep 5, 2013 at 1:43 PM, Dave Jones <davej@redhat.com> wrote:
>  > > Signed-off-by: Dave Jones <davej@fedoraproject.org>
>  > 
>  > Acked-by: Neal Cardwell <ncardwell@google.com>
>  > 
>  > neal
> 
> Crap, I forgot the 
> 
> introduced in eed530b6c67624db3f2cf477bac7c4d005d8f7ba ("tcp: early retransmit")
> 
> Dave, shall I resend ?

I'll take care of it.
