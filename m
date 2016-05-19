From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: irda: avoid null pointer dereference
Date: Thu, 19 May 2016 11:31:28 -0700 (PDT)
Message-ID: <20160519.113128.294975638415382569.davem@davemloft.net>
References: <1463522762-11144-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xypron.glpk@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463522762-11144-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Date: Wed, 18 May 2016 00:06:02 +0200

> Only dereference variable self after checking it is not NULL.
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

Applied.
