From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Is keepalive behaving as expected in 3.7.0+/net-next?
Date: Sun, 30 Dec 2012 12:51:47 -0800
Message-ID: <50E0A963.6080900@hp.com>
References: <50D4DD28.30903@hp.com> <1356645265.30414.1542.camel@edumazet-glaptop> <50df48f4.0e5b650a.36fa.1452@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <erdnetdev@gmail.com>, netdev@vger.kernel.org
To: Jamie Gloudon <jamie.gloudon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:12980 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754955Ab2L3Uvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 15:51:48 -0500
In-Reply-To: <50df48f4.0e5b650a.36fa.1452@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Make a lot of sense. However, I got the impression from Rick that
> having tcp_keepalive_intvl > tcp_keepalive_time behaved correctly in
> older versions of the kernel.

I seek to make no assertions about the behaviour of older kernels.  I 
was just going off the ip-sysctl.txt wording I was looking to clean-up.

rick
