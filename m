From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: resurrecting tcphealth
Date: Sun, 15 Jul 2012 09:16:37 +0200
Message-ID: <1342336597.3265.10617.camel@edumazet-glaptop>
References: <dee325378a2d3b7792da9640fc14905f.squirrel@webmail.univie.ac.at>
	 <20120714144800.7f8c97f6@nehalam.linuxnetplumber.net>
	 <b93cddfd0a19158ec59823140d1e2075.squirrel@webmail.univie.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Piotr Sawuk <a9702387@unet.univie.ac.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:38651 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085Ab2GOHQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2012 03:16:42 -0400
In-Reply-To: <b93cddfd0a19158ec59823140d1e2075.squirrel@webmail.univie.ac.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-07-15 at 01:43 +0200, Piotr Sawuk wrote:

> oh, and again I recommend the really short although outdated thesis
> 
> [1] https://sacerdoti.org/tcphealth/tcphealth-paper.pdf

A thesis saying SACK are not useful is highly suspect.

Instead of finding why they behave not so good and fix the bugs, just
say "SACK addition to TCP is not critical"

Really ?
