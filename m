From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 21 Sep 2012 14:58:48 -0400 (EDT)
Message-ID: <20120921.145848.1437653204908742943.davem@davemloft.net>
References: <20120921113009.29a296b6405b96b4d3c05f84@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, bjorn@mork.no
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120921113009.29a296b6405b96b4d3c05f84@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 21 Sep 2012 11:30:09 +1000

> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/usb/qmi_wwan.c between commit 9db273f45686 ("net:
> qmi_wwan: adding Huawei E367, ZTE MF683 and Pantech P4200") from the
> net tree and commit bd877e489126 ("net: qmi_wwan: use a single bind
> function for all device types") from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

Thanks Stephen, this should be resolved over the weekend as I plan
to do a merge during this time.
