From: jamal <hadi@cyberus.ca>
Subject: Re: FW: Submission for S2io 10GbE driver
Date: 24 Jan 2004 12:54:16 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1074966855.1732.8.camel@jzny.localdomain>
References: <1074914062.1036.39.camel@jzny.localdomain>
	 <000001c3e238$62efbb30$0400a8c0@S2IOtech.com>
	 <20040124155809.15fe167e.ak@suse.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Leonid Grossman <leonid.grossman@s2io.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040124155809.15fe167e.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Leonid,

What would also be interesting to see is a packet that never leaves
the kernel such is in forwarding. If theres a way you can stash two of
those cards in a box and just have them forward packets coming in from
one to another - would be nice to see the numbers with varying packet
size example { 64,256,512,1518, 4K, 9K} 

cheers,
jamal
