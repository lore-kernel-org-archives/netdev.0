From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.5.69 IPv6 (modular) crash on boot
Date: Tue, 06 May 2003 20:16:18 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030506.201618.39175334.davem@redhat.com>
References: <20030506232037.GA5576@twibble.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: lenehan@twibble.org
In-Reply-To: <20030506232037.GA5576@twibble.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jamie Lenehan <lenehan@twibble.org>
   Date: Wed, 7 May 2003 09:20:37 +1000

   IPv6 worked fine in 2.5.68, but I get a crash in 2.5.69 on boot. I
   haven't seen anyone else mention this though. This is a RedHat 8
   systems with the new modutils added and pretty much everything built
   modular:
   
Yes, we know it's broken and we're thinking about how
to fix it...
