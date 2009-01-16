From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: Sending complete IPv6 packets without bypassing netfilter/IPsec
Date: Fri, 16 Jan 2009 16:09:53 +0200
Message-ID: <200901161609.53283.remi.denis-courmont@nokia.com>
References: <8CB45DED3262281-2F30-8C9@webmail-stg-d07.sysops.aol.com> <200901161256.15744.remi.denis-courmont@nokia.com> <8CB45E27B3643B3-2F30-917@webmail-stg-d07.sysops.aol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "ext jpo234@netscape.net" <jpo234@netscape.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:27770 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935371AbZAPOKd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 09:10:33 -0500
In-Reply-To: <8CB45E27B3643B3-2F30-917@webmail-stg-d07.sysops.aol.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 16 January 2009 13:12:40 ext jpo234@netscape.net, you wrote:
> R=C3=A9mi,
> sorry, but a transport-layer raw socket is something I'd like to avoi=
d.
> The reason is, that I get the ready made packets from a tun device.

Then you have the source address from the packet read from the TUN devi=
ce.

--=20
R=C3=A9mi Denis-Courmont
Maemo Software, Nokia Devices R&D

