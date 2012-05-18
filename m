From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: [RFC] econet: remove ancient bug ridden protocol
Date: Fri, 18 May 2012 08:31:47 +0300
Message-ID: <201205180831.47820.remi@remlab.net>
References: <20120517205951.462d336f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oyp.chewa.net ([91.121.6.101]:35946 "EHLO oyp.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758236Ab2ERFcA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 01:32:00 -0400
In-Reply-To: <20120517205951.462d336f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   Hello,

Shouldn't this patch remove ec_ptr from struct net_device?

--=20
R=E9mi Denis-Courmont
http://www.remlab.info
