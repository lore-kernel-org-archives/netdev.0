From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: linear sk_buff
Date: Wed, 5 May 2010 22:35:08 +0300
Message-ID: <201005052235.09108.remi@remlab.net>
References: <o2kdac45061005051212na062f611m1c87240c367b5d38@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Mark Ryden <markryde@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:37503 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754980Ab0EETl3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 15:41:29 -0400
In-Reply-To: <o2kdac45061005051212na062f611m1c87240c367b5d38@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 5 mai 2010 22:12:06 Mark Ryden, vous avez =E9crit :
> Hello,
>  I would appreciate if someone in this mailing list  can say in a
> sentence or two what is a linear
> sk_buff and what is a non linear sk_buff; does it has to do with
> fragmentation? (I am sure that many know the answer, but I am confuse=
d and
> googling made me overconfused)

A linear sk_buff is one that has no memory pages and no fragments sk_bu=
ff.

Such a buffer is made of a contiguous portion of the (kernel) memory.


--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
http://fi.linkedin.com/in/remidenis
