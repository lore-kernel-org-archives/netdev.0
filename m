From: Amir Vadai <amirv@mellanox.com>
Subject: Re: mlx4 w/ IOMMU broken, kernel 3.12.6
Date: Thu, 9 Jan 2014 09:54:15 +0200
Message-ID: <20140109075411.GA27750@mtl-eit-vdi-22.mtl.labs.mlnx>
References: <20140108134917.GC351037@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:62739 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbaAIHyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 02:54:21 -0500
Received: by mail-ea0-f179.google.com with SMTP id r15so1274353ead.38
        for <netdev@vger.kernel.org>; Wed, 08 Jan 2014 23:54:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140108134917.GC351037@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

What is the firmware version?
You can get it by issuing 'ethtool -i <interface>'

Please make sure you're using the latest FW from mellanox.com.

We still don't have MLNX_OFED package that supports this kernel.

Amir.
