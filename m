From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 0/2] ARM: dts: NSP: Add built-in Ethernet switch nodes
Date: Mon, 11 Jul 2016 16:29:11 -0700
Message-ID: <57842BC7.3050801@gmail.com>
References: <1468003769-26959-1-git-send-email-f.fainelli@gmail.com>
 <20160708200759.GK8426@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	bcm-kernel-feedback-list@broadcom.com, jon.mason@broadcom.com,
	vivien.didelot@savoirfairelinux.com,
	linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34810 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752297AbcGKX3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 19:29:14 -0400
In-Reply-To: <20160708200759.GK8426@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/08/2016 01:07 PM, Andrew Lunn wrote:
> On Fri, Jul 08, 2016 at 11:49:27AM -0700, Florian Fainelli wrote:
>> This patch series is based on Broadcom/stblinux/devicetree/next which
>> contains proper support for the BCM958625HR board. To get working
>> Ethernet switch and CPU Ethernet support, the following dependencies
>> based on David Miller's net-next tree are required:
> 
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Both applied, thanks!
-- 
Florian
