From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Phonet: sockets list through proc_fs
Date: Mon, 20 Jul 2009 03:43:28 -0700 (PDT)
Message-ID: <20090720.034328.193709571.davem@davemloft.net>
References: <200907201247.23020.remi.denis-courmont@nokia.com>
	<1248085261.4549.103.camel@violet>
	<200907201332.05329.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49033
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751789AbZGTKnX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jul 2009 06:43:23 -0400
In-Reply-To: <200907201332.05329.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "R=E9mi Denis-Courmont" <remi.denis-courmont@nokia.com>
Date: Mon, 20 Jul 2009 13:32:04 +0300

> On Monday 20 July 2009 13:21:01 ext Marcel Holtmann wrote:
>> > It's just like most network protocols exposing their sockets list =
in
>> > /proc/net. Debugging/monitoring indeed.
>>
>> I think that for new protocols, we should not do this anymore and ju=
st
>> use debugfs. Since that is exactly its job.
>=20
> Requiring debugfs for something like 'netstat' sounds restrictive to =
me...

Me too.
