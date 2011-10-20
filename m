From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: iwlagn: WARN_ON() in iwl_get_idle_rx_chain_count()
Date: Thu, 20 Oct 2011 20:57:56 +0200
Message-ID: <20111020185756.GA24185@rere.qmqm.pl>
References: <20111014150219.GA20672@rere.qmqm.pl>
 <1318606158.12009.2.camel@wwguy-ubuntu>
 <20111014192105.GA23640@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Intel Linux Wireless <ilw@linux.intel.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: wwguy <wey-yi.w.guy@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:53327 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751422Ab1JTS57 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Oct 2011 14:57:59 -0400
Content-Disposition: inline
In-Reply-To: <20111014192105.GA23640@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 14, 2011 at 09:21:05PM +0200, Micha=B3 Miros=B3aw wrote:
> On Fri, Oct 14, 2011 at 08:29:18AM -0700, wwguy wrote:
> > Could you try the attach patch and see if it fix your problem.
> [attached patch removed]
> Backported and applied. I'll test it for couple of days.

I haven't tripped on the warnings in those last days with your
patch applied. I think the backported version should be included
in 3.1.

Best Regards,
Micha=B3 Miros=B3aw
