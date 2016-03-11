From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/2] of_mdio: use IS_ERR_OR_NULL() and PTR_ERR_OR_ZERO()
Date: Sat, 12 Mar 2016 01:11:49 +0300
Message-ID: <4882738.uyje2ICxKW@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: grant.likely@linaro.org, robh+dt@kernel.org,
	devicetree@vger.kernel.org, f.fainelli@gmail.com,
	netdev@vger.kernel.org, frowand.list@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:34057 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932952AbcCKWLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 17:11:54 -0500
Received: by mail-lb0-f176.google.com with SMTP id xr8so168267154lbb.1
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 14:11:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

   Here's the set of 2 patches against DaveM's 'net-next.git' repo. They
replace the patch posted earlier today which was clearly insufficient...

[1/2] of_mdio: use IS_ERR_OR_NULL()
[2/2] of_mdio: use PTR_ERR_OR_ZERO()

MBR, Sergei
