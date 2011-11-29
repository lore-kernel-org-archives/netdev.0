From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Daughterboard Jetway JAD3RTLANG with three RTL-8110SC/8169SC Gigabit Ethernet is curious
Date: Wed, 30 Nov 2011 00:04:04 +0100
Message-ID: <20111129230404.GB11127@electric-eye.fr.zoreil.com>
References: <jb0d7u$bbb$1@dough.gmane.org> <201111291012.25426.carsten@wolffcarsten.de> <4ED4E946.40209@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Markus Feldmann <feldmann_markus@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42698 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753308Ab1K2XKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 18:10:18 -0500
Content-Disposition: inline
In-Reply-To: <4ED4E946.40209@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Markus Feldmann <feldmann_markus@gmx.de> :
[...]
> You mean the latest Linux kernel was patched for a better
> initialization? At the moment i am using the kernel 3.0.8. As i
> understood the firmware must be loaded at every power on.

What do you mean ? Afaik there is no out-of-driver firmware for the
(old) 8169sc.

Can either of you or Carsten compare and send 'lspci -vv' before and
after windows installs ?

-- 
Ueimor
