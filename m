From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][RESEND] Update of tcp_syncookies explanation
Date: Tue, 01 Apr 2003 09:47:25 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030401.094725.01304107.davem@redhat.com>
References: <Pine.LNX.4.44.0304011911270.22637-200000@laptop1.agatha>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: blueflux@koffein.net
In-Reply-To: <Pine.LNX.4.44.0304011911270.22637-200000@laptop1.agatha>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Oskar Andreasson <blueflux@koffein.net>
   Date: Tue, 1 Apr 2003 19:33:13 +0200 (CEST)

   If anyone has any objections against this patch, please tell me so, with 
   an explanation of why! 
   
You didn't explain how TCP syncookies "seriously violates the TCP
protocol" yet you choose to remove that statement written by Alexey.

Either retain Alexey's statement (because it's true) or replace it
with proper text.

I'm not going into the details of how syncookies violates the TCP
protocol here, that has been hashed out many times on netdev and
linux-net years in the past, so I direct people to search up such
discussions instead of starting up yet another flame war here about
the topic.  Thanks.
