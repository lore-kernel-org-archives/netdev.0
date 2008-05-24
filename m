From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: network interface *name* alias support?
Date: Sat, 24 May 2008 22:54:14 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0805242254020.19084@fbirervta.pbzchgretzou.qr>
References: <alpine.LNX.1.10.0805231817100.25193@fbirervta.pbzchgretzou.qr>  <4836FB73.2010709@intel.com> <4837026A.6000702@hp.com>  <1211569604.11907.37.camel@perihelion>  <20080523225435.GT20815@postel.suug.ch>  <1211603155.11907.79.camel@perihelion>
 <alpine.LNX.1.10.0805240646380.19084@fbirervta.pbzchgretzou.qr>  <20080524051630.GD20890@auslistsprd01.us.dell.com>  <4837DCA4.5070806@katalix.com> <1211621632.31212.73.camel@shinybook.infradead.org> <48387B18.2090300@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Woodhouse <dwmw2@infradead.org>,
	James Chapman <jchapman@katalix.com>,
	Matt Domsch <Matt_Domsch@dell.com>,
	Jon Masters <jonathan@jonmasters.org>,
	Thomas Graf <tgraf@suug.ch>, Rick Jones <rick.jones2@hp.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>, johnathan@jonmasters.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:44340 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760299AbYEXUyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2008 16:54:16 -0400
In-Reply-To: <48387B18.2090300@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Saturday 2008-05-24 22:31, Patrick McHardy wrote:
> David Woodhouse wrote:
>> On Sat, 2008-05-24 at 10:15 +0100, James Chapman wrote:
>> > Wouldn't it be better to fix any applications that can't handle
>> > renamed devices?
>> 
>> _Are_ there any such applications? Other than NetworkManager crapping
>> itself when the device name is too long, I'm not aware of any.
>
> iptraf uses device names to determine the device type:

Run `iptraf -u`, and it works with any name.
