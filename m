From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: Creating virtual interface using C++
Date: Sun, 16 Jan 2011 16:43:15 +0200
Message-ID: <201101161643.15508.remi@remlab.net>
References: <AANLkTikcHuHGD4eEmuZr4+p9MSLbySmQwsr_Dj==AZ-y@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Chin Shi Hong <cshong87@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:42771 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752641Ab1APOnS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jan 2011 09:43:18 -0500
In-Reply-To: <AANLkTikcHuHGD4eEmuZr4+p9MSLbySmQwsr_Dj==AZ-y@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Hello,

Le dimanche 16 janvier 2011 16:37:05 Chin Shi Hong, vous avez =E9crit :
> Can someone give me suggestion for C++ codes that will create a
> virtual network interface

It depends what you mean by virtual. Normally, you should use /dev/net/=
tun=20
which is documented at linux-2.6/Documentation/networking/tuntap.txt

> for the existing network interface
> (including wired and wireless network interface)?

But that part of your question does not make any sense.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
http://fi.linkedin.com/in/remidenis
