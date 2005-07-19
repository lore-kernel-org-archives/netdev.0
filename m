From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] NETCONSOLE must depend on INET
Date: Tue, 19 Jul 2005 14:01:04 -0700 (PDT)
Message-ID: <20050719.140104.68160812.davem@davemloft.net>
References: <20050719182919.GA5531@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262006AbVGSVFB@vger.kernel.org>
To: bunk@stusta.de
In-Reply-To: <20050719182919.GA5531@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Tue, 19 Jul 2005 20:29:19 +0200

> NETCONSOLE=y and INET=n results in the following compile error:

Also applied, thanks Adrian.
