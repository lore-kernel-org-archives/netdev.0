From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: autotest question
Date: Mon, 15 Sep 2008 14:33:48 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0809151433001.7365@shark.he.net>
References: <97949e3e0809151337r4dc69f8cydd92074bb10088d8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Mandeep Singh Baines <msb@google.com>, netdev@vger.kernel.org
To: Laurent Chavey <chavey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:52411 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1757392AbYIOVdw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2008 17:33:52 -0400
Received: from shark.he.net ([66.160.160.2]) by xenotime.net for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 14:33:48 -0700
In-Reply-To: <97949e3e0809151337r4dc69f8cydd92074bb10088d8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Sep 2008, Laurent Chavey wrote:

> how many control file can we have per sub directories.
> I would like to have a glag_test/ directory with multiple testes (lldp
> test, af_pkt)
> each tests are independent of each other and use to verify a CL.
> 
> 
> 
> example:
>   /depot/autotest/client/site_tests/glag_tests
>     control
>     glag_lldp_test.py
>     glag_afpacket_test.py
>     glag_linkup_test.py
> 
>     etc...
> --

Does the netdev mailing list care about this question?
I.e., seems like the wrong mailing list to me.

-- 
~Randy
