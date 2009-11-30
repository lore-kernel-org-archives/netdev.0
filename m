From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: MERGE check, net-next-2.6...
Date: Mon, 30 Nov 2009 16:20:35 -0500
Message-ID: <20091130212035.GF21401@tuxdriver.com>
References: <20091129.011709.11078985.davem@davemloft.net> <8DD2590731AB5D4C9DBF71A877482A903E332F65@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"amit@netxen.com" <amit@netxen.com>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33412 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752784AbZK3V0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 16:26:04 -0500
Content-Disposition: inline
In-Reply-To: <8DD2590731AB5D4C9DBF71A877482A903E332F65@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 30, 2009 at 12:54:48PM -0800, Allan, Bruce W wrote:
> >-----Original Message-----
> >From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> >On Behalf Of David Miller
> >Sent: Sunday, November 29, 2009 1:17 AM
> >To: netdev@vger.kernel.org
> >Cc: Kirsher, Jeffrey T; linville@tuxdriver.com; amit@netxen.com
> >Subject: MERGE check, net-next-2.6...
> >
> >
> >I just merged net-2.6 into net-next-2.6, there were several
> >conflicts.
> >
> >They happened in e1000e, ath9k, generic ieee80211, and the
> >netxen driver.
> >
> >Please check my work and send any necessary fixes.
> >
> >Thanks!
> 
> Your merge conflict fix-ups for e1000e look good to me.  Thanks!

The wireless bits seem alright too...

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
