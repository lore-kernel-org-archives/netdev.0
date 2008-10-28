From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: r8169 MAC addresses broken
Date: Tue, 28 Oct 2008 21:37:36 +0100
Message-ID: <m3mygoxxpr.fsf@maximus.localdomain>
References: <490380C8.6070003@simon.arlott.org.uk>
	<4903947A.3060206@gmail.com>
	<20081025223443.GA30913@electric-eye.fr.zoreil.com>
	<4904A7C5.7090801@gmail.com>
	<20081026174654.GB24790@electric-eye.fr.zoreil.com>
	<4906E4BE.9050304@gmail.com> <m3mygozvd4.fsf@maximus.localdomain>
	<490718C7.3010501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Simon Arlott <simon@fire.lp0.eu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Ivan Vecera <ivecera@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:50041 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752723AbYJ1Uhi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2008 16:37:38 -0400
In-Reply-To: <490718C7.3010501@gmail.com> (Jiri Slaby's message of "Tue\, 28 Oct 2008 14\:51\:03 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Slaby <jirislaby@gmail.com> writes:

> No, it helped after reverting that patch. I think we don't want defunct 2.6.28
> with these nics.

No doubt.

Just to be sure, with the patch back, is the MAC read as zero again?
I'll check it too, have 8111.
-- 
Krzysztof Halasa
