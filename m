From: Ankit Jain <radical@corewars.org>
Subject: some queries
Date: Sat, 15 Jun 2002 14:24:48 +0530 (IST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.33L2.0206151420410.4436-100000@radical.corewars.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <owner-netdev@oss.sgi.com>
To: <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

Hi,

I have been trying to find answers to some queries but noone seems to be
able to help. My queries are: (kernel 2.4.18)

1. what is tcp_ehash_bucket used for? hash table for tcp sockets? what
does the "e" is the ehash mean/represent?

2. Why is a tcp control socket created at init time in tcp_v4_init(..) ?
Its of SOCK_RAW type and its unhashed to make sure that it doesnt receive
any incoming packets. why? is it used to set some options or something?
Where is it used?

Hoping for a reply!! :)

-Ankit
