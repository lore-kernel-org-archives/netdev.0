From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: fscked clock sources revisited
Date: Mon, 30 Jul 2007 19:07:29 -0700
Message-ID: <1185847649.2683.6.camel@laptopd505.fenrus.org>
References: <1185844239.5162.17.camel@localhost>
	 <1185844218.2683.0.camel@laptopd505.fenrus.org>
	 <1185844629.5162.20.camel@localhost>  <1185844980.5162.23.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Robert.Olsson@data.slu.se,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:38225 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964863AbXGaCKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 22:10:14 -0400
In-Reply-To: <1185844980.5162.23.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-07-30 at 21:23 -0400, jamal wrote:
> On Mon, 2007-30-07 at 21:17 -0400, jamal wrote:
> 
> >  Actually iirc, hpet is not even enabled in the
> > kernel -
> 
> Sorry, i lied - the config file is on my laptop - it is enabled.

is it also on in the bios? (and if not, can you grab the patches to
force enable it instead?)
(they're in the -hrt patchkit and iirc also in -mm)
-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

