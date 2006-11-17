From: chunkeey@web.de
Subject: Re: [PATCH wireless-2.6-git] prism54: WPA/RSN support for fullmac cards
Date: Fri, 17 Nov 2006 22:35:37 +0100
Message-ID: <200611172235.37797.chunkeey@web.de>
References: <200610031457.33215.chunkeey@web.de> <d120d5000611171302u110573b6y195220895ef61ba8@mail.gmail.com> <d120d5000611171309va45b92ah8f3f4a579a3a742d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:41865 "EHLO
	fmmailgate01.web.de") by vger.kernel.org with ESMTP
	id S1753092AbWKQVfk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 16:35:40 -0500
To: "Dmitry Torokhov" <dmitry.torokhov@gmail.com>
In-Reply-To: <d120d5000611171309va45b92ah8f3f4a579a3a742d@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>
> Btw, it usually locks up under heavyish load. I.e. if I just ssh into
> my devel box and code in vi it will stay jsut fine for hours. But
> FTPing stuff over quite often locks it up.

k, I've seen this phenomenon too, but on my a PCI card.

Alright, when you come home, you should check the syslogs for these 
kind of "timeout" messages. 
