From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] Add missing braces to do_tcp_setsockopt
Date: Thu, 5 Sep 2013 13:58:47 -0400
Message-ID: <20130905175847.GB5682@redhat.com>
References: <20130905174333.GA3021@redhat.com>
 <CADVnQy=_pXCdJH_qVyz6MOr-2Qo3FahYK4itThmaa2YKJm2PgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54123 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752250Ab3IER7A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Sep 2013 13:59:00 -0400
Content-Disposition: inline
In-Reply-To: <CADVnQy=_pXCdJH_qVyz6MOr-2Qo3FahYK4itThmaa2YKJm2PgA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 05, 2013 at 01:55:48PM -0400, Neal Cardwell wrote:
 > On Thu, Sep 5, 2013 at 1:43 PM, Dave Jones <davej@redhat.com> wrote:
 > > Signed-off-by: Dave Jones <davej@fedoraproject.org>
 > 
 > Acked-by: Neal Cardwell <ncardwell@google.com>
 > 
 > neal

Crap, I forgot the 

introduced in eed530b6c67624db3f2cf477bac7c4d005d8f7ba ("tcp: early retransmit")

Dave, shall I resend ?

	Dave
