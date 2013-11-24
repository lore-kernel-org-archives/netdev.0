From: "Holger Hoffstaette" <holger.hoffstaette@googlemail.com>
Subject: Re: r8169 - it's dead jim
Date: Sun, 24 Nov 2013 01:07:53 +0100
Message-ID: <pan.2013.11.24.00.07.53.246148@googlemail.com>
References: <529105F8.9030901@nurealm.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:45811 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755840Ab3KXAIE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Nov 2013 19:08:04 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1VkNF5-0000Ht-Ai
	for netdev@vger.kernel.org; Sun, 24 Nov 2013 01:08:03 +0100
Received: from p5b0068c1.dip0.t-ipconnect.de ([91.0.104.193])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 24 Nov 2013 01:08:03 +0100
Received: from holger.hoffstaette by p5b0068c1.dip0.t-ipconnect.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 24 Nov 2013 01:08:03 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 23 Nov 2013 12:46:00 -0700, James Feeney wrote:

> Going from 3.12.0-1-ARCH to 3.12.1-1-ARCH, the r8169 module is having the
> "link detect" problem again.

3.12.1 didn't contain any r8169 changes, and my cards in 2 different
machines work just fine. Maybe a micro-fractured connector or cable kink?

-h
