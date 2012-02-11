From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Subject: Re: Multiple GRE tunnels on the same host, only one routes incoming packets
Date: Sat, 11 Feb 2012 14:59:52 +0400
Message-ID: <318741328957992@web13.yandex.ru>
References: <201202111040.q1BAeESi014636@hope.more-right-rudder.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rick Koshi <netdev@more-right-rudder.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward20.mail.yandex.net ([95.108.253.145]:35541 "EHLO
	forward20.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753039Ab2BKLKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2012 06:10:09 -0500
In-Reply-To: <201202111040.q1BAeESi014636@hope.more-right-rudder.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



11.02.2012, 14:40, "Rick Koshi" <netdev@more-right-rudder.com>:

> Is this "working as designed?" =9AWhat I'd like to have happen,
> of course, is for all packets on both tunnels to be properly
> forwarded. =9AIs this possible?

Maybe you should try the "key" param to ip tunnel command?

--=20
wbr, Oleg.
