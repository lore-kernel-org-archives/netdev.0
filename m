From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: Use ioctl() to list all network interfaces.
Date: Thu, 6 Jan 2011 18:11:06 +0200
Message-ID: <201101061811.06847.remi@remlab.net>
References: <AANLkTi=Xb4TuKcCd-DgN5ZnYzRHV1RjDScyjRkqyb4P+@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Chin Shi Hong <cshong87@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:48902 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752692Ab1AFQLJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 11:11:09 -0500
In-Reply-To: <AANLkTi=Xb4TuKcCd-DgN5ZnYzRHV1RjDScyjRkqyb4P+@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 6 janvier 2011 17:33:39 Chin Shi Hong, vous avez =E9crit :
> My application's role is to display all network interfaces, including
> the network interface which are down.

You should use if_nameindex() then.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
http://fi.linkedin.com/in/remidenis
