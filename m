From: Lan Xue <lanxue@soe.ucsc.edu>
Subject: assign IP address to NIC
Date: Thu, 18 Nov 2004 22:27:23 -0800 (PST)
Message-ID: <Pine.GSO.4.58.0411182216000.13153@moondance.cse.ucsc.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I was wondering how does the Linux kernel assign IP addresses to NICs
within the localhost. Say
a host have multiple NICs, and it has got multiple IP addresses, how to
map/bind the IP address to the corresponding adapter?   What
are the APIs to achieve that? Basically, it's sth that ifconfig does
internally...

Thanks,

Lan
