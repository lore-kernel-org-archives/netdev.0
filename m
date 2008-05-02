From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: Re: [DCCP] kernel BUG on connecting
Date: Fri, 2 May 2008 22:52:36 +0200
Message-ID: <200805022252.36579.tomasz@grobelny.oswiecenia.net>
References: <200805021545.16399.tomasz@grobelny.oswiecenia.net> <20080502142110.GA4751@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:4778 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765212AbYEBUxD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 16:53:03 -0400
In-Reply-To: <20080502142110.GA4751@gerrit.erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia Friday 02 of May 2008, Gerrit Renker napisa=B3:
> With regard to your bug - did you build the full kernel or just the
> modules? You seem to lack room in the skb, if only the modules were
> built (but not the changed kernel core), this would be a likely cause=
=2E
>=20
Yes, indeed. Rebuild helped. Thanks a lot for quick help.
--=20
Regards,
Tomasz Grobelny
