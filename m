From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek r8168C / r8169 driver VLAN TAG stripping
Date: Sun, 16 Jan 2011 20:20:17 +0100
Message-ID: <20110116192017.GA3569@electric-eye.fr.zoreil.com>
References: <AANLkTi=qVSEh=RyzJ6y4kQvJW+hxqWMh2gAMmhk7GGob@mail.gmail.com> <AANLkTimqkJ3DGBX5iREEcx6sgAM+2CZHNWMU+noNSitp@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Anand Raj Manickam <anandrm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:47432 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753599Ab1APTVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jan 2011 14:21:07 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTimqkJ3DGBX5iREEcx6sgAM+2CZHNWMU+noNSitp@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anand Raj Manickam <anandrm@gmail.com> :
[...]
> This happens on a Linux 2.6.30.8 kernel .The driver is  in-kernel.

I do not notice it with my 8168c (XID 18000000) on a modular 2.6.37-git.

Can you send the XID of the r8169 that appears in the log of your kernel
and upgrade to a more recent kernel ?

-- 
Ueimor
