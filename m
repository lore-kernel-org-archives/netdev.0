From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.69] Bridge timer performance enhancement
Date: Fri, 09 May 2003 21:35:43 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030509.213543.70190877.davem@redhat.com>
References: <20030509132012.598602ec.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, bridge@math.leidenuniv.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030509132012.598602ec.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Fri, 9 May 2003 13:20:12 -0700

   Existing bridge code was waking up every jiffie then scanning
   internal structures for what internal timers had expired.

You're going to have to redo the rest of these bridging
patches since I'm not going to apply the one which kills off
destructor usage.
