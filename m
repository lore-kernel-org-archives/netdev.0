From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [Madwifi-devel] ar5k and Atheros AR5005G
Date: Wed, 29 Nov 2006 15:05:47 +0100
Message-ID: <200611291505.47405.mb@bu3sch.de>
References: <1164746352.31456.22.camel@systems03.lan.brontes3d.com> <200611282145.08423.mb@bu3sch.de> <40f31dec0611290555t42d28247x7f163527fac438c1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Daniel Drake" <ddrake@brontes3d.com>, netdev@vger.kernel.org,
	madwifi-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:43484
	"EHLO vs166246.vserver.de") by vger.kernel.org with ESMTP
	id S967185AbWK2OIG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 09:08:06 -0500
To: "Nick Kossifidis" <mickflemm@gmail.com>
In-Reply-To: <40f31dec0611290555t42d28247x7f163527fac438c1@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 29 November 2006 14:55, Nick Kossifidis wrote:
> I 've already ported ar5k to linux and it works with madwifi versions

No, you misunderstood me.
Madwifi is not a native driver and will never be accepted into
mainline. My attempt is to write a native d80211 driver based
on the ar5k sources. Currently I don't have too much time, so
it's not very progressed, but from next week on I have vacation
from work, so I think I can work on this again.

-- 
Greetings Michael.
