From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 1/7] X25: Add if_x25.h and x25 to device identifiers
Date: Tue, 20 Apr 2010 16:35:58 -0700 (PDT)
Message-ID: <20100420.163558.83598373.davem@davemloft.net>
References: <1271719717.2802.77.camel@ibex>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew.hendry@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55665
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751767Ab0DTXfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 19:35:54 -0400
In-Reply-To: <1271719717.2802.77.camel@ibex>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Hendry <andrew.hendry@gmail.com>
Date: Tue, 20 Apr 2010 09:28:37 +1000

> diff --git a/include/linux/if_x25.h b/include/linux/if_x25.h
> new file mode 100644
> index 0000000..897765f
> --- /dev/null
> +++ b/include/linux/if_x25.h
> @@ -0,0 +1,26 @@
> +/*
> + *  Linux X.25 packet to device interface

Headers meant to be used by userspace must be added
to the include/linux/Kbuild file.
