From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 1/2] net: dsa: use DEVICE_ATTR_RW to declare temp1_max
Date: Thu, 16 Apr 2015 15:13:40 -0400 (EDT)
Message-ID: <767234291.775722.1429211620271.JavaMail.zimbra@savoirfairelinux.com>
References: <1429209499-2447-1-git-send-email-vivien.didelot@savoirfairelinux.com> <553005B5.9000101@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	kernel@savoirfairelinux.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:65292 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715AbbDPTNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 15:13:45 -0400
In-Reply-To: <553005B5.9000101@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Sergei,

> > Since commit da4759c, sysfs will only use the permissions returned by
> 
>     Please also specify that commit's summary line in parens.

Duly noted.

da4759c is "sysfs: Use only return value from is_visible for the file mode"
(see: https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=da4759c)

Best,
-v
