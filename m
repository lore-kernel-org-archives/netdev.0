From: Zoltan NAGY <nagyz@nefty.hu>
Subject: IPv6 bridging
Date: Thu, 02 Dec 2004 18:58:47 +0100
Message-ID: <41AF57D7.10608__15135.6533905075$1102032959$gmane$org@nefty.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
Resent-Message-Id: <20041203.091439.108453871.yoshfuji@wide.ad.jp>
To: linux-kernel@vger.kernel.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

Is it possible to bridge ip tunnels (IPv6 in IPv4)? brctl gives me an 
error "Invalid argument",
and from strace it seems it misses some ioctls from kernel...

any ideas?

I need it to be able to give my UMLs a public ipv6 address.

Regrads,

Zoltan NAGY,
Software Engineer

