From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/Makefile: conditionally descend to wireless and
 ieee802154
Date: Tue, 29 Jun 2010 15:32:54 -0700 (PDT)
Message-ID: <20100629.153254.63029948.davem@davemloft.net>
References: <20100627120025.0232a9d0@absol.kitzblitz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nikai@nikai.net
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <20100627120025.0232a9d0@absol.kitzblitz>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Kaiser <nikai@nikai.net>
Date: Sun, 27 Jun 2010 12:00:25 +0200

> Don't descend to wireless and ieee802154 unless they are actually used.
> 
> Signed-off-by: Nicolas Kaiser <nikai@nikai.net>

Applied.
