From: Meelis Roos <mroos@linux.ee>
Subject: Re: Problem with Compaq NC3131 dual eth card
Date: Tue, 06 Jan 2004 20:13:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1Advho-0000Pq-3c@rhn.tartu-labor>
References: <20040106151751.GB1509622@hiwaay.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: cmadams@hiwaay.net, netdev@oss.sgi.com
In-Reply-To: <20040106151751.GB1509622@hiwaay.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

CA> I have a Compaq NC3131 dual 10/100 ethernet PCI (64/32 bit in a 32 bit
CA> slot) card.  The e100 module doesn't work, and the eepro100 module can
CA> be coerced to work but complains about it (this is with Fedora Core 1
CA> and kernel-2.4.22-1.2135.nptl.athlon.rpm).

FWIW, I have a NC3134 (64/66 in 32/33 slot). Just tested it with
2.6.1-rc1 and 2.4.25-pre4, works fine and transfers fine. I tried only
e100 since it just worked.

-- 
Meelis Roos
