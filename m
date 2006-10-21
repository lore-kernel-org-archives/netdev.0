From: Pawel Foremski <pjf@asn.pl>
Subject: Re: [RFC] Ethernet Cheap Cryptography
Date: Sat, 21 Oct 2006 17:33:43 +0200
Message-ID: <ehdekn$62f$1@sea.gmane.org>
References: <200610151820.22867.dpc@asn.pl> <17717.40394.531846.695392@localhost.localdomain> <200610181115.12471.dpc@asn.pl> <17718.63424.509719.492216@localhost.localdomain> <eh87aq$71t$1@sea.gmane.org> <17720.12801.843076.819750@localhost.localdomain> <ehbava$iia$1@sea.gmane.org> <17721.32425.591879.97484@localhost.localdomain> <20061020192826.7ed05816@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7Bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:5592 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S2993091AbWJUPeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2006 11:34:02 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1GbIrB-0001Vz-Lx
	for netdev@vger.kernel.org; Sat, 21 Oct 2006 17:33:53 +0200
Received: from demiurg.asn.pl ([85.14.84.18])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 21 Oct 2006 17:33:53 +0200
Received: from pjf by demiurg.asn.pl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 21 Oct 2006 17:33:53 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

> Ethernet encrypted bridging is old stuff:
> http://kerneltrap.org/node/167
> http://www.arnor.net/encryptingbridge/
> 
> It never got accepted, mostly for the same reasons this proposal
> is a dead end.

>From what I can see in the brief description is that ccrypt is more general
as it is not limited to ethernet bridging code, UDP and AES.

Unfortunately I cannot find any replies to the announcement you've mentioned
and thus I am and was not aware of the objections to the encrypted bridging
idea.

I knew the encrypted bridging project before starting to think about ccrypt,
BTW.

-- 
Pawel Foremski
pjf@asn.pl

