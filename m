From: "Mike Snitzer" <snitzer@gmail.com>
Subject: Re: [PATCH 1/1] bonding: eliminate RTNL assertion spew
Date: Wed, 15 Aug 2007 14:36:27 -0400
Message-ID: <170fa0d20708151136q1535672dvbc90271afe80ec6f@mail.gmail.com>
References: <20070109225900.GA11755@gospo.rdu.redhat.com>
	 <20070109150935.6ec3ce69@localhost>
	 <20070110193355.GA13249@gospo.rdu.redhat.com>
	 <170fa0d20708142014l217b8804g66426a84547ba91d@mail.gmail.com>
	 <bdfc5d6e0708142027i669347aasa935bb277b2bbb48@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@osdl.org>,
	"Jeff Garzik" <jeff@garzik.org>, fubar@us.ibm.com,
	netdev@vger.kernel.org
To: "Andy Gospodarek" <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:2296 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbXHOSg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 14:36:29 -0400
Received: by py-out-1112.google.com with SMTP id u77so16631pyb
        for <netdev@vger.kernel.org>; Wed, 15 Aug 2007 11:36:27 -0700 (PDT)
In-Reply-To: <bdfc5d6e0708142027i669347aasa935bb277b2bbb48@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'd very much like to help out.  The "rtnl assertion spew" isn't
instilling confidence in customers I've been working with.  If you'd
like to send me patches in private I'd help test them ASAP.

Could you elaborate on the associated risk of _not_ fixing these
issues?  balance-alb _seems_ to be working even though these traces
occur on initialization.  But these rtnl traces are clearly more
generic than balance-alb.

regards,
Mike

On 8/14/07, Andy Gospodarek <andy@greyhouse.net> wrote:
> On 8/14/07, Mike Snitzer <snitzer@gmail.com> wrote:
> > Andy,
> >
> > Is there an updated version of this patch?
> >
> > Please advise, thanks.
> >
> >
>
> Mike,
>
> There is a version that Jay and I have been testing and if you would
> like to help out, we could probably send you some patches.
>
> Jay has split the entire patch into smaller chunks, and we hope to
> post the entire thing quite soon (days not months).
>
> -andy
>
