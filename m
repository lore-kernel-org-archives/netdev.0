From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 8/8] ftgmac100: Document device-tree binding
Date: Thu, 13 Apr 2017 15:42:50 +0200
Message-ID: <20170413134250.GD16424@lunn.ch>
References: <20170412224443.17906-1-benh@kernel.crashing.org>
 <20170412224443.17906-9-benh@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57573 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752465AbdDMNmv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 09:42:51 -0400
Content-Disposition: inline
In-Reply-To: <20170412224443.17906-9-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +- phy-mode: See ethernet.txt file in the same directory. If the property is
> +  absent, "rgmii" is assumed. Supported values are "rgmii" and "rmii"

You might want to say rgmii*, or similar, it indicate the delayed
versions are accepted as well.

	 Andrew
