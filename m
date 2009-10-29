From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: pull request: wireless-next-2.6 2009-10-28
Date: Thu, 29 Oct 2009 15:14:40 +0100
Message-ID: <200910291514.40318.bzolnier@gmail.com>
References: <200910291212.41656.bzolnier@gmail.com> <200910291435.54203.bzolnier@gmail.com> <84144f020910290652n2e75827dk698b238b6bd1cbed@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linville@tuxdriver.com
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:28496 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754293AbZJ2OP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 10:15:27 -0400
In-Reply-To: <84144f020910290652n2e75827dk698b238b6bd1cbed@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

On Thursday 29 October 2009 14:52:50 Pekka Enberg wrote:
> Hi Bart,
> 
> On Thu, Oct 29, 2009 at 3:35 PM, Bartlomiej Zolnierkiewicz
> <bzolnier@gmail.com> wrote:
> >> I'm saying that you should work with John to have him send a revert or
> >> whatever to me.
> >
> > This is your responsibility to deal with your downstream maintainers,
> > not mine and since you have accepted John's patch I'm asking you to
> > revert rt2800pci patch from your tree.
> 
> So why don't you just send a patch to fix it up? I see you're doing

"git revert a9b3a9f"

done.

Dave, if you have problems with executing the command locally I'll be
happy to supply you with the patch.

> lots of cleanups to the staging drivers, why not direct some of that
> energy to the drivers/net/wireless ones?

When did we start to apply "fix it yourself" rule instead of "submitter
should fix it" one to the _new_ code..

rt2800 drivers have their maintainers and I would like to know what they
are doing besides complaining about users and staging tree..

-- 
Bartlomiej Zolnierkiewicz
