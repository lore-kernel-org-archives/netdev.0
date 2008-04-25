From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [RFC] updated Patch to option HSO driver to the kernel
Date: Fri, 25 Apr 2008 15:03:30 +0200
Message-ID: <200804251503.31240.oliver@neukum.org>
References: <20080417214719.GF17664@kroah.com> <480F3C41.10908@teltonika.lt> <4811CF33.8040007@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:36211 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753701AbYDYMuf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 08:50:35 -0400
In-Reply-To: <4811CF33.8040007@teltonika.lt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 25. April 2008 14:31:47 schrieb Paulius Zaleckas:
> - do we really need ethtool support? It always reports that
> =C2=A0 =C2=A0link is up... The only useful information is driver name=
,
> =C2=A0 =C2=A0version and USB path... Is it worth it?

Yes. NetworkManager does strange things to devices without ethtool
support. NetworkManager is important.

	Regards
		Oliver

