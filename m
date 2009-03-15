From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [BUG] 2.6.29-rc7 broke r8169 MAC on Thecus n2100 ARM board
Date: Sun, 15 Mar 2009 11:09:53 +0100
Message-ID: <20090315100953.GA16632@electric-eye.fr.zoreil.com>
References: <200903092029.n29KT1DS004531@harpo.it.uu.se> <20090313201511.GA27827@electric-eye.fr.zoreil.com> <9e246b4d0903131921k6fba9b04ge945c2902d4117d0@mail.gmail.com> <18875.38673.270977.133982@pilspetsen.it.uu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tim Durack <tdurack@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, ivecera@redhat.com
To: Mikael Pettersson <mikpe@it.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40503 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752702AbZCOKHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2009 06:07:46 -0400
Content-Disposition: inline
In-Reply-To: <18875.38673.270977.133982@pilspetsen.it.uu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mikael Pettersson <mikpe@it.uu.se> :
[...]
> May I suggest that 6709fe9a27e43a4931938fe0d7f2cc5edef31386 is reverted
> until this regression is debugged and fixed?

Yes.

-- 
Ueimor
