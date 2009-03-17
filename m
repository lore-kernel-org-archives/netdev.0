From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: socket api problem: can't bind an ipv6 socket to ::ffff:0.0.0.0
Date: Tue, 17 Mar 2009 09:51:35 +0100
Message-ID: <87y6v41qi0.fsf@nemi.mork.no>
References: <20090316233934.GD32111@codeblau.de> <49BF0A5A.2040501@hp.com>
	<49BF0F4D.7000409@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:59135 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753177AbZCQIvs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2009 04:51:48 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1LjV1W-0007yF-Ht
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 08:51:46 +0000
Received: from 193.160.199.2 ([193.160.199.2])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2009 08:51:46 +0000
Received: from bjorn by 193.160.199.2 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2009 08:51:46 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <dada1@cosmosbay.com> writes:

> RFC 2373 states :

I fully agree with your interpretation...

=2E.., but just FYI, RFC 2373 was obsoleted by RFC 3513 which in turn w=
as
obsoleted by RFC 4291.  Among the important changes was the deprecation
of the first address class you quote (the ::a.b.c.d addresses).

This doesn't affect the question though.



Bj=C3=B8rn

