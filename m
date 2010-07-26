From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: tcpdump <-> FCoE support
Date: Mon, 26 Jul 2010 21:22:14 +0200
Message-ID: <20100726192214.GA2937@nuttenaction>
References: <D3F292ADF945FB49B35E96C94C2061B90C6F53AE@nsmail.netscout.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@open-fcoe.org, netdev@vger.kernel.org
To: "Loke, Chetan" <Chetan.Loke@netscout.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:40805 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751632Ab0GZTWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 15:22:17 -0400
Content-Disposition: inline
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B90C6F53AE@nsmail.netscout.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Loke, Chetan | 2010-07-26 13:30:13 [-0400]:

>13:08:21.907971 00:yy:yy:yy:yy:yy (oui Unknown) > 00:xx:xx:xx:xx:xx (oui
>Unknown), ethertype Unknown (0x8906)
>
>On: tcpdump-4.0.0-3, tcpdump doesn't seem to have FCoE support(unless I
>capture it and pipe it to wireshark). Is there any effort currently in
>progress on adding FCoE parsers?

That's no kernel issue, it is purely related to userland tools such as
tcpdump/wireshark/whatever.

Hagen

