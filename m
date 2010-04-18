From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 6/6] X25: Use identifiers for hdlc x25 device to x25 interface
Date: Sun, 18 Apr 2010 14:39:16 +0200
Message-ID: <m3eiid540b.fsf@intrepid.localdomain>
References: <1271584429.6280.435.camel@ibex>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andrew Hendry <andrew.hendry@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:55230 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757252Ab0DRMjS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Apr 2010 08:39:18 -0400
In-Reply-To: <1271584429.6280.435.camel@ibex> (Andrew Hendry's message of
	"Sun, 18 Apr 2010 19:53:49 +1000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Hendry <andrew.hendry@gmail.com> writes:

> Change magic numbers to identifiers for X25 interface.

Looks good to me, ack.

> Note, x25_connect_disconnect 'reason' appears unimplemented?

To be honest, I don't know this stuff at all. I've added it years ago to
the point some x25 telnet (or something like that) connected to some
server, then I had a successful confirmation from somebody. Personally
I don't even enable X.25 in my tests. I don't know if someone is still
using this code.
-- 
Krzysztof Halasa
