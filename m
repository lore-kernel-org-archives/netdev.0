From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v9 4/4] net: rtnetlink - make create_link take
 name_assign_type
Date: Tue, 15 Jul 2014 16:19:03 -0700 (PDT)
Message-ID: <20140715.161903.318866372308191765.davem@davemloft.net>
References: <1405348645-1995-1-git-send-email-teg@jklm.no>
	<1405348645-1995-4-git-send-email-teg@jklm.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: teg@jklm.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405348645-1995-4-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tom Gundersen <teg@jklm.no>
Date: Mon, 14 Jul 2014 16:37:25 +0200

> This passes down NET_NAME_USER (or NET_NAME_ENUM) to alloc_netdev(),
> for any device created over rtnetlink.
> 
> v9: restore reverse-christmas-tree order of local variables
> 
> Signed-off-by: Tom Gundersen <teg@jklm.no>

Applied.
