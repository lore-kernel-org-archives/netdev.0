From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] econet: remove ancient bug ridden protocol
Date: Fri, 18 May 2012 01:41:48 -0400 (EDT)
Message-ID: <20120518.014148.360953579106644334.davem@davemloft.net>
References: <20120517205951.462d336f@nehalam.linuxnetplumber.net>
	<201205180831.47820.remi@remlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: remi@remlab.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38315 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755375Ab2ERFmw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 01:42:52 -0400
In-Reply-To: <201205180831.47820.remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "R=E9mi Denis-Courmont" <remi@remlab.net>
Date: Fri, 18 May 2012 08:31:47 +0300

> Shouldn't this patch remove ec_ptr from struct net_device?

I took care of it with a follow-on patch.
