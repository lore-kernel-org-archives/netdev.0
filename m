From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxge: should include tcp.h
Date: Sat, 04 Apr 2009 16:36:26 -0700 (PDT)
Message-ID: <20090404.163626.254076633.davem@davemloft.net>
References: <a4423d670904030234l3734ad45t49009e8ede2e1d2d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, netdev@vger.kernel.org,
	ram.vepa@neterion.com
To: a.beregalov@gmail.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <a4423d670904030234l3734ad45t49009e8ede2e1d2d@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Beregalov <a.beregalov@gmail.com>
Date: Fri, 3 Apr 2009 13:34:40 +0400

> Fix this build error:
> 
> drivers/net/vxge/vxge-main.c: In function 'vxge_get_vpath_no':
> drivers/net/vxge/vxge-main.c:695: error: dereferencing pointer to
> incomplete type
> ...
> 
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>

Applied, thanks!
