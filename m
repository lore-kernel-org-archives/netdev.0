From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET_CLS_RSVP6 should depend on IPV6
Date: Sat, 14 Jul 2007 17:36:14 +0200
Message-ID: <4698ED6E.6020502@trash.net>
References: <4698A7B6.1030302@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@vger.kernel.org
To: Gabriel C <nix.or.die@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35992 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbXGNPhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 11:37:00 -0400
In-Reply-To: <4698A7B6.1030302@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gabriel C wrote:
> cls_rsvp6 only works with IPV6 enabled kernels and IMO it should depends
> on IPV6.


I can't see any functional dependency on IPv6, what exactly are you
refering to? People might want to use it on a bridge for example
without having IPv6 running locally.


