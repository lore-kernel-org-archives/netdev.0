From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] handle slip module unload race better.
Date: Thu, 12 Jun 2003 17:55:32 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030612.175532.78736834.davem@redhat.com>
References: <20030612132714.6b8e1267.shemminger@osdl.org>
	<20030612.145803.112592736.davem@redhat.com>
	<20030612161243.01052de0.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@parcelfarce.linux.theplanet.co.uk, jgarzik@pobox.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030612161243.01052de0.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Thu, 12 Jun 2003 16:12:43 -0700
   
   Okay, this patch does that. I could start and unload slip, but could
   not actually trigger the failure.

Applied, thanks.
