From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Make sure sockets implement splice_read
Date: Fri, 15 Feb 2008 17:30:11 +0100
Message-ID: <p73k5l6yygc.fsf@bingen.suse.de>
References: <200802141853.35016.rdenis@simphalempin.com>
	<20080215.023601.219994317.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rdenis@simphalempin.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39372 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752415AbYBOQaN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 11:30:13 -0500
In-Reply-To: <20080215.023601.219994317.davem@davemloft.net> (David Miller's message of "Fri\, 15 Feb 2008 02\:36\:01 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: R=E9mi_Denis-Courmont <rdenis@simphalempin.com>
> Date: Thu, 14 Feb 2008 18:53:34 +0200
>
>> Fixes a segmentation fault when trying to splice from a non-TCP sock=
et.
>>=20
>> Signed-off-by: R=E9mi Denis-Courmont <rdenis@simphalempin.com>
>
> Applied, thank you.

That's also a stable candidate, isn't it?=20

-Andi
