From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 2/2 net-next] caif_usb: use target structure member
 in memset
Date: Tue, 14 Oct 2014 16:06:02 -0400 (EDT)
Message-ID: <20141014.160602.1746747507486023769.davem@davemloft.net>
References: <1413306074-8401-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, joe@perches.com,
	dmitry.tarnyagin@lockless.no, netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413306074-8401-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Tue, 14 Oct 2014 19:01:14 +0200

> parent cfusbl was used instead of first structure member 'layer'
> 
> Suggested-by: Joe Perches <joe@perches.com>
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
