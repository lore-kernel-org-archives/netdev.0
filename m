From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-2.6.24 0/5]: TCP sacktag cache usage recoded
Date: Wed, 10 Oct 2007 03:45:52 -0700 (PDT)
Message-ID: <20071010.034552.123972190.davem@davemloft.net>
References: <11906297271684-git-send-email-ilpo.jarvinen@helsinki.fi>
	<20071010.025829.106434530.davem@davemloft.net>
	<Pine.LNX.4.64.0710101300221.3767@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, sangtae.ha@gmail.com,
	virtualphtn@gmail.com, baruch@ev-en.org, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35787
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752972AbXJJKpt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 06:45:49 -0400
In-Reply-To: <Pine.LNX.4.64.0710101300221.3767@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 10 Oct 2007 13:26:05 +0300 (EEST)

> Hmm, SACK code is under such flux currently that I'll=20
> have to deal conflicts almost daily due to overlapping ideas...

Welcome to my world, just scale it to 800 patches and entire
networking tree :-))))

