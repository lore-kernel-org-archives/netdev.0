From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFT] Realtek 8168 ethernet support
Date: Sun, 11 Jun 2006 00:48:11 +0200
Message-ID: <20060610224811.GA3256@electric-eye.fr.zoreil.com>
References: <20060601200200.A0E0689D05D@zog.reactivated.net> <20060608143133.7e36a0b7.rdunlap@xenotime.net> <4488DF85.3090901@garzik.org> <20060609183358.GA5835@electric-eye.fr.zoreil.com> <4489C290.6020705@garzik.org> <20060610120523.GA24288@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Randy.Dunlap" <rdunlap@xenotime.net>,
	Daniel Drake <dsd@gentoo.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:11715 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1750723AbWFJWtP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jun 2006 18:49:15 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <20060610120523.GA24288@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> :
[...]
> -> the != ... && ... != test above seems inverted.

Answering to myself: yes, it is. The 8100 and 8101 are PCI Express
fast ethernet only (but they should do 802.1q, go figure).

-- 
Ueimor
