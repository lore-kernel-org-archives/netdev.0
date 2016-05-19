From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: pegasus: remove dead coding
Date: Thu, 19 May 2016 11:35:42 -0700 (PDT)
Message-ID: <20160519.113542.960620764938295044.davem@davemloft.net>
References: <1463530410-12772-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: petkan@nucleusys.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xypron.glpk@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463530410-12772-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Date: Wed, 18 May 2016 02:13:30 +0200

> (!count || count < 4) is always true.
> So let's remove the coding which is dead at least since 2005.
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

Applied.
