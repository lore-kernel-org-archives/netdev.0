From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Default TCP Options creating problems
Date: Fri, 27 Jan 2012 16:20:18 +0100
Message-ID: <1327677618.32615.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4F22B17A.2080809@gmail.com>
	 <1327675774.2220.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F22C81A.8090800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nanda Kumar <heramba85@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:50724 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753740Ab2A0PUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 10:20:21 -0500
Received: by werb13 with SMTP id b13so1313347wer.19
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2012 07:20:20 -0800 (PST)
In-Reply-To: <4F22C81A.8090800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 27 janvier 2012 =C3=A0 21:21 +0530, Nanda Kumar a =C3=A9cri=
t :

> Thank you for the reply. Yes even I feel so. I have put up this issue=
 to=20
> ISP.
>=20
> However this issue is happening only with TCP timestamp option. All=20
> other options are working fine. Any idea?
>=20

If you disable all options but tcp timestamps, what happens ?
