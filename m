From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: au1000 eth: simplify logical expression
Date: Thu, 19 May 2016 11:32:22 -0700 (PDT)
Message-ID: <20160519.113222.2192500593132505774.davem@davemloft.net>
References: <1463529525-12504-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, ivecera@redhat.com,
	a@unstable.cc, fw@strlen.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xypron.glpk@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463529525-12504-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Date: Wed, 18 May 2016 01:58:45 +0200

> (a && a > 0) is equivalent to (a > 0).
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

Applied.
