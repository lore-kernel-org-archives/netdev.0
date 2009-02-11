From: Risto Suominen <risto.suominen@gmail.com>
Subject: Re: [PATCH 002/002] de2104x: support for systems lacking cache
	coherence
Date: Wed, 11 Feb 2009 14:31:43 +0200
Message-ID: <46e1c7760902110431p54c0b5f7oa1a07726f4db5021@mail.gmail.com>
References: <46e1c7760902090022g1d903ca0nf314f0c1cc6b07c8@mail.gmail.com>
	 <m3vdrja6oe.fsf@intrepid.localdomain>
	 <46e1c7760902091122m6ec7fbb5nefd9cc9789880c0f@mail.gmail.com>
	 <20090210.152143.176850113.davem@davemloft.net>
	 <46e1c7760902110418n276de9b2xa2169839b9e25dc0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:48229 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751873AbZBKMbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 07:31:46 -0500
Received: by bwz5 with SMTP id 5so237070bwz.13
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2009 04:31:43 -0800 (PST)
In-Reply-To: <46e1c7760902110418n276de9b2xa2169839b9e25dc0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As an interesting side effect, the patch caused my mesh module to stop
working. It crashes.

Risto
