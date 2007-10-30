From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 2/2] [IPV6] ADDRCONF: Support RFC3484 configurable
 address selection policy table.
Date: Tue, 30 Oct 2007 00:40:02 -0700 (PDT)
Message-ID: <20071030.004002.82654399.davem@davemloft.net>
References: <20071030.145254.120595012.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52543
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752797AbXJ3HkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 03:40:21 -0400
In-Reply-To: <20071030.145254.120595012.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Tue, 30 Oct 2007 14:52:54 +0900 (JST)

> diff --git a/include/linux/if_addrlabel.h b/include/linux/if_addrlabel.h
> new file mode 100644
> index 0000000..66978a5
> --- /dev/null
> +++ b/include/linux/if_addrlabel.h
> @@ -0,0 +1,55 @@
> +/*
> + * ifaddrlabel.h - netlink interface for address labels
> + *
> + * Copyright (C)2007 USAGI/WIDE Project,  All Rights Reserved.
> + *
> + * Redistribution and use in source and binary forms, with or without
> + * modification, are permitted provided that the following conditions
> + * are met:

Please, this is just a very primitive header file definiting a
simplistic struct and a few enumerations.  Can't you just GPL it with
just the USAGI/WIDE copyright line, instead of using this complicated
license text?

If it important for the USAGI Project to take credit for this work,
they will receive it fully in the copyright line and the changelog
entry.

Thank you.
