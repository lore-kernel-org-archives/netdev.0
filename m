From: "David S. Miller" <davem@redhat.com>
Subject: Re: kernel BUG at net/core/skbuff.c:1028!
Date: Wed, 07 May 2003 04:20:35 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030507.042035.13750321.davem@redhat.com>
References: <20030507121412.GI823@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: axboe@suse.de
In-Reply-To: <20030507121412.GI823@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jens Axboe <axboe@suse.de>
   Date: Wed, 7 May 2003 14:14:12 +0200

   Booting 2.5-BK on my little router BUG's out before the login is
   reached. 100% reproduceable. Let me know if you want more detail.

I forwarded this to Rusty, I think netfilter changes he made
recently have caused this.
