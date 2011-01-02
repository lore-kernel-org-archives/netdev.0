From: "=?iso-8859-15?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Sun, 2 Jan 2011 22:16:04 +0200
Message-ID: <201101022216.04863.remi@remlab.net>
References: <1293982286-15389-1-git-send-email-stefani@seibold.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: stefani@seibold.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:43167 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751421Ab1ABUYG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jan 2011 15:24:06 -0500
In-Reply-To: <1293982286-15389-1-git-send-email-stefani@seibold.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 2 janvier 2011 17:31:26 stefani@seibold.net, vous avez =E9c=
rit :
> UDPCP is a communication protocol specified by the Open Base Station
> Architecture Initiative Special Interest Group (OBSAI SIG). The
> protocol is based on UDP and is designed to meet the needs of "Mobile
> Communcation Base Station" internal communications. It is widely used=
 by
> the major networks infrastructure supplier.

Unless I missed something, you did not declare the new lock classes for=
 the=20
lock consistency checks.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
http://fi.linkedin.com/in/remidenis
