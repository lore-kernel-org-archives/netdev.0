From: "=?ISO-8859-1?Q?Ra=FAl_Hern=E1ndez?=" <rauhersu@gmail.com>
Subject: routing PF_PACKET sockets
Date: Mon, 22 Sep 2008 01:10:54 +0200
Message-ID: <3f847c820809211610n731b0090wb6a9f94a3514f455@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:63060 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753188AbYIUXKz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2008 19:10:55 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1316466rvb.1
        for <netdev@vger.kernel.org>; Sun, 21 Sep 2008 16:10:54 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

I am trying to understand the possible options on dealing with
PF_PACKET and routing schemas: does the packet bypass the linux
routing table (as it is opened directly over a 'dev'). Might this
behaviour be configurable ? Thanks !

Best regards,
Ra=FAl

--=20
Security is mostly a superstition. It does not exist in nature nor do
the children of man as a whole experience it. Avoiding danger is no
safer in the long run than outright exposure. Life is either a daring
adventure, or nothing - Helen Keller
