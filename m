From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.70] remove if_port_text
Date: Thu, 29 May 2003 20:15:23 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030529.201523.83619362.davem@redhat.com>
References: <20030529104138.751a1f54.shemminger@osdl.org>
	<20030529.140828.78714529.davem@redhat.com>
	<20030529142820.5f657d77.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, scott.feldman@intel.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030529142820.5f657d77.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Thu, 29 May 2003 14:28:20 -0700

   Eliminate necrophilic code, net-sysfs shouldn't support deprecated
   if_port.  Since nowhere else is using if_port_text, eliminate it.
   
Applied, thanks Stephen.
