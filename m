From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: IPsec AH use of ahash
Date: Sun, 20 Jan 2013 20:30:49 +0000
Message-ID: <8b7b5c2c-1e9f-4390-8492-a21cf8566d55@email.android.com>
References: <1361595885.93211.1358703620681.JavaMail.root@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tom St Denis <tstdenis@elliptictech.com>,
	David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:59468 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752452Ab3ATUbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 15:31:04 -0500
In-Reply-To: <1361595885.93211.1358703620681.JavaMail.root@elliptictech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Look at it from the kernel end. What happens if your change shows up bugs on another architecture or has a flaw. It works for you now but you plan to dump and run. That's not a viable long term development model for upstream.

The licence allows you to do it, and other parties who care more to pick it up and run with it. Unless someone does however it's just a burden. If nobody wants it upstream enough better it stays out perhaps - if the call is wrong eventually other people will care enoug to share the work. If not you get to pick between doing the extra or re-porting your code to new releases 

Alan
