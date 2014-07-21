From: Brandon Applegate <brandon@burn.net>
Subject: Dump (former) route cache (i.e. PMTU info)
Date: Mon, 21 Jul 2014 16:24:16 -0400 (EDT)
Message-ID: <alpine.DEB.2.02.1407211623590.17165@orbital.burn.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="2110710444-1127023894-1405974256=:17165"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbital.burn.net ([206.125.172.226]:44924 "EHLO
	orbital.burn.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821AbaGUUYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 16:24:17 -0400
Received: from localhost (localhost [127.0.0.1])
	by orbital.burn.net (Postfix) with ESMTP id E82D92EB1E
	for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 16:24:16 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--2110710444-1127023894-1405974256=:17165
Content-Type: TEXT/PLAIN; format=flowed; charset=ISO-8859-7
Content-Transfer-Encoding: 8BIT

I see that linux-net list is no more, therefore I¢m posting here.

I¢m aware that the route cache has been removed as of 2012 
(http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=89aef8921bfbac22f00e04f8450f6e447db13e42)

Before that - I was able to do ¡ip route show table cache¢ and see all 
cached PMTU info.

The closest thing I can find now is to pull info on a single entry with 
¡ip route get x.x.x.x¢

Is there a way currently to get the old behavior and display all entries 
at once ?

Thanks.

--
Brandon Applegate - CCIE 10273
PGP Key fingerprint:
830B 4802 1DD4 F4F9 63FE  B966 C0A7 189E 9EC0 3A74
"SH1-0151.  This is the serial number, of our orbital gun."

--2110710444-1127023894-1405974256=:17165--
