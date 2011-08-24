From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/10][pull request] Complete drivers/net/ move
Date: Wed, 24 Aug 2011 10:31:41 -0700 (PDT)
Message-ID: <20110824.103141.222234551992546689.davem@davemloft.net>
References: <1314176570-20298-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752762Ab1HXRb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 13:31:57 -0400
In-Reply-To: <1314176570-20298-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 24 Aug 2011 02:02:40 -0700

> The following are changes since commit 131ea6675c761f655d43b808dd0fe83d15d5cdd3:
>   net: add APIs for manipulating skb page fragments.
> and are available in the git repository at:
>   master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/next-organize master

Try again:

ERROR: "pppox_ioctl" [net/l2tp/l2tp_ppp.ko] undefined!
ERROR: "unregister_pppox_proto" [net/l2tp/l2tp_ppp.ko] undefined!
ERROR: "register_pppox_proto" [net/l2tp/l2tp_ppp.ko] undefined!
ERROR: "ppp_input" [net/l2tp/l2tp_ppp.ko] undefined!
ERROR: "pppox_unbind_sock" [net/l2tp/l2tp_ppp.ko] undefined!
ERROR: "ppp_register_net_channel" [net/l2tp/l2tp_ppp.ko] undefined!
ERROR: "ppp_dev_name" [net/l2tp/l2tp_ppp.ko] undefined!
ERROR: "ppp_unit_number" [net/irda/irnet/irnet.ko] undefined!
ERROR: "ppp_unregister_channel" [net/irda/irnet/irnet.ko] undefined!
ERROR: "ppp_output_wakeup" [net/irda/irnet/irnet.ko] undefined!
ERROR: "ppp_input_error" [net/irda/irnet/irnet.ko] undefined!
ERROR: "ppp_input" [net/irda/irnet/irnet.ko] undefined!
ERROR: "ppp_register_channel" [net/irda/irnet/irnet.ko] undefined!
ERROR: "ppp_channel_index" [net/irda/irnet/irnet.ko] undefined!
ERROR: "ppp_input_error" [net/atm/pppoatm.ko] undefined!
ERROR: "ppp_input" [net/atm/pppoatm.ko] undefined!
ERROR: "ppp_unregister_channel" [net/atm/pppoatm.ko] undefined!
ERROR: "ppp_output_wakeup" [net/atm/pppoatm.ko] undefined!
ERROR: "ppp_unit_number" [net/atm/pppoatm.ko] undefined!
ERROR: "ppp_channel_index" [net/atm/pppoatm.ko] undefined!
ERROR: "ppp_register_channel" [net/atm/pppoatm.ko] undefined!
ERROR: "ppp_unit_number" [drivers/tty/ipwireless/ipwireless.ko] undefined!
ERROR: "ppp_unregister_channel" [drivers/tty/ipwireless/ipwireless.ko] undefined!
ERROR: "ppp_output_wakeup" [drivers/tty/ipwireless/ipwireless.ko] undefined!
ERROR: "ppp_input" [drivers/tty/ipwireless/ipwireless.ko] undefined!
ERROR: "ppp_register_channel" [drivers/tty/ipwireless/ipwireless.ko] undefined!
ERROR: "ppp_channel_index" [drivers/tty/ipwireless/ipwireless.ko] undefined!
ERROR: "slhc_init" [drivers/isdn/i4l/isdn.ko] undefined!
ERROR: "slhc_remember" [drivers/isdn/i4l/isdn.ko] undefined!
ERROR: "slhc_uncompress" [drivers/isdn/i4l/isdn.ko] undefined!
ERROR: "slhc_free" [drivers/isdn/i4l/isdn.ko] undefined!
ERROR: "slhc_compress" [drivers/isdn/i4l/isdn.ko] undefined!
