From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 6/7] net: dsa: mv88e6xxx: add number of database
 to info
Date: Fri, 15 Apr 2016 21:35:16 +0200
Message-ID: <20160415193516.GD18523@lunn.ch>
References: <1460744750-13896-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1460744750-13896-7-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58011 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752608AbcDOTfU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Apr 2016 15:35:20 -0400
Content-Disposition: inline
In-Reply-To: <1460744750-13896-7-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 15, 2016 at 02:25:49PM -0400, Vivien Didelot wrote:
> Move the number of databases to the info structure.

Isn't the number of databases a property of the family?

I would add a table indexed by family.

  Andrew
