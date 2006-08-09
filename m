From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take6 0/3] kevent: Generic event handling mechanism.
Date: Wed, 9 Aug 2006 12:24:42 +0400
Message-ID: <20060809082442.GA18957@2ka.mipt.ru>
References: <11551105592821@2ka.mipt.ru> <20060809.005856.104034268.davem@davemloft.net> <20060809080754.GA29783@2ka.mipt.ru> <20060809.012045.21594448.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: linux-kernel@vger.kernel.org, drepper@redhat.com,
	netdev@vger.kernel.org, zach.brown@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:64978 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S965101AbWHIIZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 04:25:11 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060809.012045.21594448.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2006 at 01:20:45AM -0700, David Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Wed, 9 Aug 2006 12:07:57 +0400
> 
> > So you want to review kevent core only at the first point and postpone
> > network AIO and the rest implementation after core is correct.
> 
> That's the idea
> 
> > Should I remove poll/timer notifications too?
> 
> That can stay


Ok, I will regenerate the lastest patchset completely without AIO stuff
(both network and VFS) and resend it soon.
Thank you.

-- 
	Evgeniy Polyakov
