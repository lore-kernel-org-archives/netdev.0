From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2 0/3] of_mdio: use IS_ERR_OR_NULL() and PTR_ERR_OR_ZERO()
Date: Sun, 13 Mar 2016 00:32:13 +0300
Message-ID: <2682275.WNlbxTfNal@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: grant.likely@linaro.org, robh+dt@kernel.org,
	devicetree@vger.kernel.org, f.fainelli@gmail.com,
	netdev@vger.kernel.org, frowand.list@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:34754 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752343AbcCLVcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 16:32:18 -0500
Received: by mail-lb0-f173.google.com with SMTP id xr8so190936243lbb.1
        for <netdev@vger.kernel.org>; Sat, 12 Mar 2016 13:32:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

   Here's the set of 3 patches against DaveM's 'net-next.git' repo. They deal
with some error checks in the device tree MDIO code...

[1/3] of_mdio: mdio_device_create() never returns NULL
[2/3] of_mdio: use IS_ERR_OR_NULL()
[3/3] of_mdio: use PTR_ERR_OR_ZERO()

MBR, Sergei
