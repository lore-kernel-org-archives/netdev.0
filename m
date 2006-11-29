From: "Michael Renzmann" <madwifi@nospam.otaku42.de>
Subject: Re: [Madwifi-devel] ar5k and Atheros AR5005G
Date: Wed, 29 Nov 2006 16:58:46 +0100 (CET)
Message-ID: <1443.194.45.26.221.1164815926.squirrel@webmail.otaku42.de>
References: <1164746352.31456.22.camel@systems03.lan.brontes3d.com>
    <200611291612.33448.mb@bu3sch.de>
    <20061129152407.GB5412@devicescape.com>
    <200611291638.56759.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Kimdon" <david.kimdon@devicescape.com>,
	"Nick Kossifidis" <mickflemm@gmail.com>,
	"Daniel Drake" <ddrake@brontes3d.com>, netdev@vger.kernel.org,
	madwifi-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from legolas.otaku42.de ([217.24.0.78]:24742 "EHLO
	legolas.otaku42.de") by vger.kernel.org with ESMTP id S935774AbWK2P67
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 10:58:59 -0500
In-Reply-To: <200611291638.56759.mb@bu3sch.de>
To: "Michael Buesch" <mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

> On Wednesday 29 November 2006 16:24, David Kimdon wrote:
>> There is absolutely no reason why dadwifi can't be merged into the
>> mainline once the hal issue is resolved.
> Last time we talked about that stuff, it was decided that
> we don't want a HAL... See archives.

IIRC Pavel already explained that getting rid of the HAL per se should be
no problem - it could easily be dissolved into the driver, if that is one
of the requirements to be fulfilled before the driver (MadWifi or DadWifi)
is considered for mainline inclusion. As soon as there is source available
to dissolve, at least.

>From what I understood the "... once the hal issue is resolved" part of
David's mail refered to exactly that question.

Bye, Mike



