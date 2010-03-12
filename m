From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: [patch 1/5] phonet: use =?UTF-8?Q?for=5Feach=5Fset=5Fbit=28=29?=
Date: Fri, 12 Mar 2010 08:34:31 +0100
Message-ID: <9131ab138d63714dcb5af26d56d0b6e9@chewa.net>
References: <201003112207.o2BM7nQn013486@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, akinobu.mita@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:39519 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751104Ab0CLHef (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Mar 2010 02:34:35 -0500
In-Reply-To: <201003112207.o2BM7nQn013486@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 11 Mar 2010 14:07:49 -0800, akpm@linux-foundation.org wrote:=0D
> From: Akinobu Mita <akinobu.mita@gmail.com>=0D
> =0D
> Replace open-coded loop with for_each_set_bit().=0D
> =0D
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>=0D
> Cc: "David S. Miller" <davem@davemloft.net>=0D
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>=0D
=0D
Acked-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net=0D
http://fi.linkedin.com/in/remidenis

