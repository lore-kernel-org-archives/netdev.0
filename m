From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: remove "PHY reset until link up" log spam
Date: Tue, 23 Jul 2013 22:23:40 +0200
Message-ID: <20130723202340.GB31567@electric-eye.fr.zoreil.com>
References: <4961229.bXDGvH0dpz@al>
 <20130723085436.70e8588c@nehalam.linuxnetplumber.net>
 <2856794.AWy189S2qk@al>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nic_swsd@realtek.com
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51226 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933789Ab3GWUXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 16:23:55 -0400
Content-Disposition: inline
In-Reply-To: <2856794.AWy189S2qk@al>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Wu <lekensteyn@gmail.com> :
[...]
> Which user wants to get log spam every ten seconds ?

In my world users - be they big workstations or runtime pm enabled
laptops - may not even care about log [1].

> I see no purpose except when a developer asks a user to turn this on,
> or except if you are a developer.

Exactly. You'll easily guess which side I'm on with my load of problem
reports that have no simple solution and slowly ages while bugfixes
flow through -stable.

> This message was added almost ten years ago, Realtek must
> certainly have improved their hardware not to be so crappy ?

With due respect to Realtek, git log or Realtek's own Release.txt file
do not exactly paint the world as a faery of unicorns.

(Realtek is not alone: manufacturers can be quite creative)

[1] Linus is not a real user.

-- 
Ueimor
