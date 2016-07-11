From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v2 net] ipv6: addrconf: fix Juniper SSL VPN client regression
Date: Mon, 11 Jul 2016 21:19:09 +0200
Message-ID: <87y4582daq.fsf@miraculix.mork.no>
References: <1468248230-5763-1-git-send-email-bjorn@mork.no>
	<7461.1468256356@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jonas Lippuner <jonas@lippuner.ca>,
	=?utf-8?B?VDA54oCmRTTigJpGMWYwRQ==?=
	<hideaki.yoshifuji@miraclelinux.com>
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:56946 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750760AbcGKTTX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 15:19:23 -0400
In-Reply-To: <7461.1468256356@turing-police.cc.vt.edu> (Valdis Kletnieks's
	message of "Mon, 11 Jul 2016 12:59:16 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Valdis.Kletnieks@vt.edu writes:

> Tested against next-20160708, and the Juniper code works fine. Feel f=
ree
> to stick a Tested-By: on the V2 patch...

Thanks to both of you for verifying that it solves the Juniper problem.

A tip: Patchworks is nice enough to automatically pick up tags from
review comments, as long as the tags start at column 0.  I haven't trie=
d
multiple tags, but let's see if this works:

Tested-by: Jonas Lippuner <jonas@lippuner.ca>
Tested-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>


Bj=C3=B8rn
