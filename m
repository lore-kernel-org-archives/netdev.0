From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: `ip addr show' shows maximum of 56 addresses?
Date: Tue, 06 Dec 2011 14:47:24 +0100
Message-ID: <1323179244.2448.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1323129923.2887.51.camel@bwh-desktop>
	 <1323143336.7454.225.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Jencks <ben@bjencks.net>, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:55844 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310Ab1LFNr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 08:47:27 -0500
Received: by vcbfk14 with SMTP id fk14so4870276vcb.19
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2011 05:47:27 -0800 (PST)
In-Reply-To: <1323143336.7454.225.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 06 d=C3=A9cembre 2011 =C3=A0 03:48 +0000, Ben Hutchings a =C3=A9=
crit :

> Seems like a candidate for 2.6.32.y.  I don't think it depends on any=
 of
> your other changes for 2.6.33, does it?

Yes, this is a candidate for 2.6.32.y, I see no dependencies.
