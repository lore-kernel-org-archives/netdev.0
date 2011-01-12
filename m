From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: TCPCT API update for 2.6.37
Date: Wed, 12 Jan 2011 12:43:00 -0500
Message-ID: <4D2DE824.10205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the recent flurry of messages related to TCPCT, I devoted a nice
snowy Saturday afternoon to updating the socket option code.  Linux is
rather behind on TCPCT implementation, so this will help with future
software compatibility.

Currently, any userland programs written to RFC-to-be-6013 will not
interoperate with Linux 2.6.33 and beyond.  I've made these patches
for 2.6.37 -- they'll also need to be ported to earlier releases.

I'm not on this list, so anybody with comments should CC me.  Thanks.
