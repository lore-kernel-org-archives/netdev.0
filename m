From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.68] [BRIDGE] More user hz conversions
Date: Tue, 29 Apr 2003 01:31:46 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429.013146.26985806.davem@redhat.com>
References: <20030428134854.21622b2b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030428134854.21622b2b.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Mon, 28 Apr 2003 13:48:54 -0700

   Several more places need USER/KERNEL HZ conversion.  Without these
   the timer values in 'brctl showmacs' and 'brctl showstp' are off.

Applied, thanks.
