From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user with the same regression
Date: Thu, 21 Aug 2008 08:33:34 -0700
Message-ID: <86802c440808210833wc3c76b5vc3a7f0d6208bf07f@mail.gmail.com>
References: <654003.23282.qm@web82104.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ingo Molnar" <mingo@elte.hu>, "Vivek Goyal" <vgoyal@redhat.com>,
	"Bill Fink" <billfink@mindspring.com>,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"Peter Zijlstra" <peterz@infradead.org>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: "David Witbrodt" <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.235]:1499 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484AbYHUPde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 11:33:34 -0400
Received: by rv-out-0506.google.com with SMTP id k40so17166rvb.1
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 08:33:34 -0700 (PDT)
In-Reply-To: <654003.23282.qm@web82104.mail.mud.yahoo.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 7:09 AM, David Witbrodt <dawitbro@sbcglobal.net> wrote:

>
> I will try to provide the entire output tonight or tomorrow.  It will be
> difficult, though:  it looks like I have to try to fit the info from about
> 60 of the printk's in your patch onto the 80x25 VGA screen, and still
> make it understandable enough to be useful.
>

with hpet=disable?

YH
