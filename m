From: "Thomas 'Dent' Mirlacher" <dent@cosy.sbg.ac.at>
Subject: Re: Linux IP stack on kernel 2.4.18
Date: Sun, 2 Jun 2002 11:39:53 +0200 (MET DST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.05.10206021139290.6283-100000@mausmaki.cosy.sbg.ac.at>
References: <3CF9DDD0.3080809@galileo.co.il>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Rabeeh Khoury <rabeeh@galileo.co.il>
In-Reply-To: <3CF9DDD0.3080809@galileo.co.il>
List-Id: netdev.vger.kernel.org

--snip/snip

> 2.. Routing jumbo packets through IP stack - I send 9K packets in size and IP stack routes the packets but by sending 1K packets in size ! is this possible ? I tripple checked the device driver on receive and transmit and it's ok. Do you know what is the problem ?

did you check you MTU?

	tm

-- 
in some way i do, and in some way i don't.
