From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.4.21 oops
Date: Mon, 16 Jun 2003 15:30:37 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030616.153037.90795159.davem@redhat.com>
References: <20030616153029.0c8f2a20.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@digeo.com
In-Reply-To: <20030616153029.0c8f2a20.akpm@digeo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andrew Morton <akpm@digeo.com>
   Date: Mon, 16 Jun 2003 15:30:29 -0700

   This kills 2.5.71++ as well.

I forwarded this to David Stevens, he last played in
this area so he might be able to fix it fast.

He obviously didn't add the bug, since it exists in 2.4.x
which doesn't have his IGMPv3 mods...
