From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] LSM networking update: summary (0/5)
Date: Sat, 08 Feb 2003 00:44:40 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030208.004440.91323755.davem@redhat.com>
References: <7B2A7784F4B7F0409947481F3F3FEF8305CC9531@eammlex037.lmc.ericsson.se>
	<Pine.LNX.4.44.0302081002400.9462-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Makan.Pourzandi@ericsson.ca, kuznet@ms2.inr.ac.ru,
   linux-security-module@wirex.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Pine.LNX.4.44.0302081002400.9462-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: James Morris <jmorris@intercode.com.au>
   Date: Sat, 8 Feb 2003 10:10:44 +1100 (EST)
   
   As mentioned during the last week, the current set of network hooks will
   not directly support explicitly labeled networking.

Why not?  I thought we had completely established that anything
the socket receive SKB hook could not handle would be implementable
via netfilter.
