From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 net-next 0/2] tcp: Redundant Data Bundling (RDB)
Date: Mon, 07 Mar 2016 14:36:53 -0500 (EST)
Message-ID: <20160307.143653.1679598829375210676.davem@davemloft.net>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
	<1457028388-18226-1-git-send-email-bro.devel+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ycheng@google.com, eric.dumazet@gmail.com,
	ncardwell@google.com, apetlund@simula.no, griff@simula.no,
	paalh@simula.no, jonassm@ifi.uio.no, kristian.evensen@gmail.com,
	kennetkl@ifi.uio.no
To: bro.devel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53404 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826AbcCGTgz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 14:36:55 -0500
In-Reply-To: <1457028388-18226-1-git-send-email-bro.devel+kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Bendik R=F8nning Opstad" <bro.devel@gmail.com>
Date: Thu,  3 Mar 2016 19:06:26 +0100

> Redundant Data Bundling (RDB) is a mechanism for TCP aimed at
> reducing the latency for applications sending time-dependent data.
 ...

Can some TCP experts please review these patches?

Thanks.
