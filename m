From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: qla3xxx network driver fills the log with "Link is down" messages
Date: Tue, 11 Nov 2008 07:54:05 -0800
Message-ID: <20081111155405.GA4328@susedev.qlogic.org>
References: <20081020184815.5e9ca743@redhat.com> <20081021143538.GA429@susedev.qlogic.org> <20081111153612.GA7868@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Ebbert <cebbert@redhat.com>, netdev@vger.kernel.org,
	linux-driver@qlogic.com
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:13940 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773AbYKKPyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 10:54:11 -0500
Content-Disposition: inline
In-Reply-To: <20081111153612.GA7868@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2008 at 10:36:12AM -0500, Dave Jones wrote:
> On Tue, Oct 21, 2008 at 07:35:38AM -0700, Ron Mercer wrote:
>  > On Mon, Oct 20, 2008 at 06:48:15PM -0400, Chuck Ebbert wrote:
>  > > https://bugzilla.redhat.com/show_bug.cgi?id=461623
>  > > 
>  > > If you try to bring up a qla3xxx adapter without any cable connected 
>  > > it fills the log with:
>  > > 
>  > > qla3xxx eth2: Link is down.
>  > > qla3xxx eth2: port_link_state = LS_DOWN.
>  > > qla3xxx eth2: Link is down.
>  > > qla3xxx eth2: port_link_state = LS_DOWN.
>  > > qla3xxx eth2: Link is down.
>  > > qla3xxx eth2: port_link_state = LS_DOWN.
>  > > qla3xxx eth2: Link is down.
>  > > qla3xxx eth2: port_link_state = LS_DOWN.
>  > > ...
>  > 
>  > Thanks for pointing this out.  I am out of town this week so will fix
>  > this and post upstream and to distros when I return next Monday.
> 
> Hey Ron,
>  Did this fall through the cracks?
> I didn't see any follow-up.
> 
> thanks,
> 
> 	Dave

I haven't forgot about it, I'm just busy with some other things.  I will
get this pushed upstream today.


