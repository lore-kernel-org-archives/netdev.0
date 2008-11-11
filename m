From: Dave Jones <davej@redhat.com>
Subject: Re: qla3xxx network driver fills the log with "Link is down"
	messages
Date: Tue, 11 Nov 2008 10:36:12 -0500
Message-ID: <20081111153612.GA7868@redhat.com>
References: <20081020184815.5e9ca743@redhat.com> <20081021143538.GA429@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Chuck Ebbert <cebbert@redhat.com>, netdev@vger.kernel.org,
	linux-driver@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:47272 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750933AbYKKPgP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 10:36:15 -0500
Content-Disposition: inline
In-Reply-To: <20081021143538.GA429@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 21, 2008 at 07:35:38AM -0700, Ron Mercer wrote:
 > On Mon, Oct 20, 2008 at 06:48:15PM -0400, Chuck Ebbert wrote:
 > > https://bugzilla.redhat.com/show_bug.cgi?id=461623
 > > 
 > > If you try to bring up a qla3xxx adapter without any cable connected 
 > > it fills the log with:
 > > 
 > > qla3xxx eth2: Link is down.
 > > qla3xxx eth2: port_link_state = LS_DOWN.
 > > qla3xxx eth2: Link is down.
 > > qla3xxx eth2: port_link_state = LS_DOWN.
 > > qla3xxx eth2: Link is down.
 > > qla3xxx eth2: port_link_state = LS_DOWN.
 > > qla3xxx eth2: Link is down.
 > > qla3xxx eth2: port_link_state = LS_DOWN.
 > > ...
 > 
 > Thanks for pointing this out.  I am out of town this week so will fix
 > this and post upstream and to distros when I return next Monday.

Hey Ron,
 Did this fall through the cracks?
I didn't see any follow-up.

thanks,

	Dave

-- 
http://www.codemonkey.org.uk
