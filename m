From: =?iso-8859-1?Q?Bj=F8rn_Mork?= <bmork@dod.no>
Subject: Re: [Bugme-new] [Bug 9811] New: Loopback address to eth0 interface changes scope permanently
Date: Fri, 25 Jan 2008 17:34:31 +0100
Message-ID: <87abmtq2y0.fsf@obelix.mork.no>
References: <bug-9811-10286@http.bugzilla.kernel.org/>
	<20080125025016.f6b08754.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bugme-daemon@bugzilla.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:37291 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753370AbYAYQen (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2008 11:34:43 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JIRVp-0000d7-3H
	for netdev@vger.kernel.org; Fri, 25 Jan 2008 16:34:41 +0000
Received: from obelix.mork.no ([148.122.252.2])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 16:34:41 +0000
Received: from bmork by obelix.mork.no with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 16:34:41 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Latest working kernel version: none
>> Earliest failing kernel version: 2.6.18 (verified, but most likely "=
any")

Looks like this was introduced in 2.1.68, which makes it a 10 year old
bug :-)=20

http://www.linuxhq.com/kernel/v2.1/68/net/ipv4/devinet.c



Bj=F8rn
--=20
You sound like a real wimp

