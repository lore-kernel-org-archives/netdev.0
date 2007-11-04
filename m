From: dean gaudet <dean@arctic.org>
Subject: Re: TCP_DEFER_ACCEPT issues
Date: Sun, 4 Nov 2007 09:18:16 -0800 (PST)
Message-ID: <alpine.DEB.0.9999.0711040916210.4696@twinlark.arctic.org>
References: <20071102013321.GA30893@codeblau.de> <472AD0AE.50106@cosmosbay.com> <20071102221912.GB4354@codeblau.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <dada1@cosmosbay.com>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Felix von Leitner <felix-linuxkernel@fefe.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from twinlark.arctic.org ([207.29.250.54]:39310 "EHLO
	twinlark.arctic.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752937AbXKDRSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Nov 2007 12:18:17 -0500
In-Reply-To: <20071102221912.GB4354@codeblau.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fwiw i also brought the TCP_DEFER_ACCEPT problems up the end of last year:

http://www.mail-archive.com/netdev@vger.kernel.org/msg28916.html

it's possible the final message in that thread is how we should define the 
behaviour, i haven't tried the TCP_SYNCNT idea though.

-dean
