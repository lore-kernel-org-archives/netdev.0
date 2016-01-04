From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 1/3] rsi: Delete unnecessary variable initialisations in
 rsi_send_mgmt_pkt()
Date: Mon, 4 Jan 2016 12:28:57 +0300
Message-ID: <20160104092857.GD5284@mwanda>
References: <566ABCD9.1060404@users.sourceforge.net>
 <5687E169.4070704@users.sourceforge.net>
 <5687E203.1070404@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Kalle Valo <kvalo@codeaurora.org>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5687E203.1070404@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches are labour intensive to review because you can't just do
it in the email client.  Also you were not able to review it properly
yourself and introduced a bug.

I am often remove initializers but it's normally because I am changing
something else which makes it worthwhile.  This patch is the correct
thing but it's not "worthwhile".  It is not a good use of my time.

Please stop sending cleanup patches, Markus.  Just send fixes.

regards,
dan carpenter
