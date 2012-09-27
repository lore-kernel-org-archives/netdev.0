From: Chad Gray <chad938@hotmail.com>
Subject: Netfilter lacks ability to filter packets via Application-origin
Date: Thu, 27 Sep 2012 17:04:56 -0400
Message-ID: <COL002-W881A56C786C9972B7654E3F3830@phx.gbl>
References: <COL002-W8067088C0C0B4682A10A0F39B0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [65.55.34.24] ([65.55.34.24]:13425 "EHLO
	col0-omc1-s14.col0.hotmail.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755230Ab2I0VFR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2012 17:05:17 -0400
In-Reply-To: <COL002-W8067088C0C0B4682A10A0F39B0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Users need the ability for Linux firewall to filter packets based on wh=
at=20
Application they are originating from. This ability is present in Mac a=
nd=20
Windows firewalls, but not Linux.=20
=A0
=46or example, users would like ability to open Port 80 for Firefox, bu=
t keep=20
Port 80 closed for other applications.=20
=A0
This ability enhances Privacy & Security of the user but also helps to =
better=20
inform the user about the comings and goings of internet traffic and wh=
at=20
application/s are causing the traffic.=20

https://bugzilla.kernel.org/show_bug.cgi?id=3D47531 		 	   		  