From: =?UTF-8?B?RMOibmllbA==?= Fraga <fragabr@gmail.com>
Subject: Re: inetd and Linux kernel 3.0
Date: Sat, 20 Aug 2011 20:48:55 -0300
Message-ID: <4e5047ea.4874ec0a.317c.ffffa715@mx.google.com>
References: <4e503565.28b8ec0a.650c.5823@mx.google.com>
	<20110820.163312.1686705823210711719.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:59613 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754697Ab1HTXs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2011 19:48:59 -0400
Received: by gya6 with SMTP id 6so2920970gya.19
        for <netdev@vger.kernel.org>; Sat, 20 Aug 2011 16:48:59 -0700 (PDT)
In-Reply-To: <20110820.163312.1686705823210711719.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 20 Aug 2011 16:33:12 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> It is trying to bind to an ipv6 address using an ipv4 socket.

	Thanks David! Exactly. I compiled inetd with ipv6 disabled and
now everything is fine.

	Thank you very much!

-- 
