From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [question] bridged tunnel
Date: Tue, 28 Jul 2009 10:43:31 +0200
Message-ID: <20090728084330.GC6522@psychotron.englab.brq.redhat.com>
References: <20090728075928.GB3633@psychotron.englab.brq.redhat.com> <200907281111.16433.remi.denis-courmont@nokia.com> <20090728081818.GA6522@psychotron.englab.brq.redhat.com> <4A6EB695.2070202@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Philip Craig <philipc@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36998 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750733AbZG1Inh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jul 2009 04:43:37 -0400
Content-Disposition: inline
In-Reply-To: <4A6EB695.2070202@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jul 28, 2009 at 10:28:05AM CEST, philipc@snapgear.com wrote:
>Jiri Pirko wrote:
>> Well generally there could be anything (e.g. internet) in between ROUTER A and
>> B. That's why.
>
>If the internet is in the middle, then you don't want to invent your own
>tunneling.  Using something like OpenVPN in tap mode, or gretap over IPSec.
>

I would like to avoid overhead that openvpn and ipsec adds. In my case only few
routers are in the middle.

