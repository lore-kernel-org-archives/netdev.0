From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] MIPS checksum fix
Date: Fri, 19 Sep 2008 16:02:38 +0100 (BST)
Message-ID: <Pine.LNX.4.55.0809191543230.29711@cliff.in.clinika.pl>
References: <20080919112304.GB13440@linux-mips.org> <20080919114743.GA19359@linux-mips.org>
 <20080919120752.GA19877@linux-mips.org> <20080919.230952.128619158.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ralf@linux-mips.org, u1@terran.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirk.serum.com.pl ([213.77.9.205]:64390 "EHLO serum.com.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751017AbYISPDD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2008 11:03:03 -0400
In-Reply-To: <20080919.230952.128619158.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Sep 2008, Atsushi Nemoto wrote:

> I think it would be better splitting bugfix and optimization.  This
> code is too complex to do many things at a time, isn't it?

 It's probably easier for people to test a single patch now and it can
then be split at the commitment time.  Of course if something actually
breaks, then keeping changes combined won't help tracking down the cause.  
;)

  Maciej
