From: Marek Vasut <marex@denx.de>
Subject: Re: Stable request 9374e7d2 "rtlwifi: rtl8192cu: Add new device ID"
Date: Tue, 28 Apr 2015 16:10:15 +0200
Message-ID: <201504281610.15973.marex@denx.de>
References: <1430229364.6036.1@alarsen-lx>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Anders Larsen <al@alarsen.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:36148 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031047AbbD1OKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 10:10:31 -0400
In-Reply-To: <1430229364.6036.1@alarsen-lx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, April 28, 2015 at 03:56:04 PM, Anders Larsen wrote:
> Hi,
> 
> commit 9374e7d2fdcad3c36dafc8d3effd554bc702c4b6
> Author: Marek Vasut <marex@denx.de>
> Date:   2015-03-26 02:16:06 +0100
> 
>      rtlwifi: rtl8192cu: Add new device ID
> 
>      Add new ID for ASUS N10 WiFi dongle.
> 
> in Linus' tree has been tested on 3.16.7 and 3.10.5x
> and applies cleanly all the way back to 3.2.68
> 
> Please consider this patch for the stable trees.

Hi,

did you check [1] please? I might be wrong, but these are
the official -stable submission guidelines to my knowledge.

[1] https://www.kernel.org/doc/Documentation/stable_kernel_rules.txt

Best regards,
Marek Vasut
