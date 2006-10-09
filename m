From: Stefan Rompf <stefan@loplof.de>
Subject: Re: cfg80211 take 7
Date: Mon, 9 Oct 2006 13:22:43 +0200
Message-ID: <200610091322.43612.stefan@loplof.de>
References: <1160146790.2715.82.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from lvps80-237-161-167.dedicated.hosteurope.de ([80.237.161.167]:53913
	"EHLO lvps80-237-161-167.dedicated.hosteurope.de") by vger.kernel.org
	with ESMTP id S932428AbWJILVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2006 07:21:24 -0400
To: Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>
In-Reply-To: <1160146790.2715.82.camel@ux156>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Freitag, 6. Oktober 2006 16:59 schrieben Sie:

> anyway, it's getting large, so... straight from quilt:
> http://johannes.sipsolutions.net/files/cfg80211/

nice work! Is there any possibility to limit the card to a specific band (e.g. 
802.11 a/b/g) using cfg80211? I'm asking because I haven't seen code to 
accomplish this in cfg80211, but I maybe wrong.

Many drivers implement this feature as an iwpriv, and I consider it useful 
enough (especially when association and roaming is kernel controlled) to 
justify a generic configuration element.

Thoughts?

Stefan
