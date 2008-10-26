From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 MAC addresses broken
Date: Sun, 26 Oct 2008 16:01:42 +0100
Message-ID: <20081026150142.GA24790@electric-eye.fr.zoreil.com>
References: <490380C8.6070003@simon.arlott.org.uk> <4903947A.3060206@gmail.com> <20081025223443.GA30913@electric-eye.fr.zoreil.com> <490448B0.8050307@gmail.com> <m33aijzfga.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Slaby <jirislaby@gmail.com>, Simon Arlott <simon@fire.lp0.eu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Ivan Vecera <ivecera@redhat.com>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:47209 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753031AbYJZPCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 11:02:16 -0400
Content-Disposition: inline
In-Reply-To: <m33aijzfga.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Halasa <khc@pm.waw.pl> :
[...]
> First the ICH* e1000e corruption and now GbE RTL.

Ok, consider the whole thing reverted.

I thought this code could be made to work for -rc1 but new
failures keep appearing. Sorry for the mess.

-- 
Ueimor
