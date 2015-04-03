From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [RFC PATCH 3/5] Rename support library for geneve
Date: Fri, 3 Apr 2015 14:25:47 -0400
Message-ID: <20150403182545.GA22162@tuxdriver.com>
References: <1428002227-11636-1-git-send-email-linville@tuxdriver.com>
 <1428002227-11636-4-git-send-email-linville@tuxdriver.com>
 <CAHA+R7Op9inHY=CvyyqgK4v7=xxntAPmZBzBYg27hxcKFF7H6A@mail.gmail.com>
 <20150403144032.GB31348@tuxdriver.com>
 <551EB79A.4070707@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34898 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753153AbbDCSaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 14:30:17 -0400
Content-Disposition: inline
In-Reply-To: <551EB79A.4070707@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 03, 2015 at 05:54:02PM +0200, Nicolas Dichtel wrote:
> Le 03/04/2015 16:40, John W. Linville a =E9crit :
> [snip]
> >Honestly, this name change seems like the simplest and least awkward
> >choice to me.  But, I am open to suggestions...
> There is already some files named '_core.c' under net/ipv4 and net/ip=
v6.
> What about geneve_core.c ?

Works for me...

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
