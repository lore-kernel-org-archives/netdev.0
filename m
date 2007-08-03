From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [TCP]: Also handle snd_una changes in tcp_cwnd_down
Date: Thu, 02 Aug 2007 19:46:20 -0700 (PDT)
Message-ID: <20070802.194620.92586428.davem@davemloft.net>
References: <Pine.LNX.4.64.0708012054180.27657@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0708021412380.8788@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56367
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753446AbXHCCqV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 22:46:21 -0400
In-Reply-To: <Pine.LNX.4.64.0708021412380.8788@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 2 Aug 2007 14:18:59 +0300 (EEST)

> Dave, please put these two patches to net-2.6 to complete bidir fix=20
> series. ...And please push to stable as well, take just the minimized=
=20
> "fix" portion of this "[TCP]: Also handle snd_una changes in=20
> tcp_cwnd_down" patch as I described above. Other cleanups in it can b=
e
> put just to net-2.6.

Ok, I will, thanks Ilpo!
