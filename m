From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.70+] Cleanup net-sysfs show and change functions
Date: Thu, 12 Jun 2003 00:00:33 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030612.000033.45899350.davem@redhat.com>
References: <20030610133854.42713231.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030610133854.42713231.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Tue, 10 Jun 2003 13:38:54 -0700

   This cleans up the network sysfs code to use helper functions to unify
   the show/change functions, by using common code in functions rather
   than template macros.
   
   The function always checks for dead devices, so I/O will fail.
   
Applied, thanks.
