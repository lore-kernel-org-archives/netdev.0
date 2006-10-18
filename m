From: David Kimdon <david.kimdon@devicescape.com>
Subject: d80211: ANNOUNCE: DadWifi, a port of MadWifi to d80211
Date: Tue, 17 Oct 2006 17:14:29 -0700
Message-ID: <20061018001403.GA22990__17721.0974311039$1161134077$gmane$org@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: madwifi-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:18087 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1751286AbWJRAOa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 20:14:30 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

DadWifi is a port of MadWifi to the d80211 stack.  It works now in
managed and monitor mode, lightly tested.  Any card supported by
MadWifi should be supported by DadWifi [1].  This allows a large
number of cards to now take advantage of the d80211 stack.

DadWifi uses the same (binary only) hal as MadWifi and reuses much of
the initialization, descriptor and interrupt processing code.

There is a subversion repository and mailing list available [2] for
those wishing to try it out or help with development.

-David


[1] : http://madwifi.org/wiki/Compatibility
[2] : https://devicescape.org/projects/dadwifi/

