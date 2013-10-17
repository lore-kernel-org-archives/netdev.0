From: David Miller <davem@davemloft.net>
Subject: Re: [patch] yam: remove a no-op in yam_ioctl()
Date: Thu, 17 Oct 2013 15:54:28 -0400 (EDT)
Message-ID: <20131017.155428.869400734081327430.davem@davemloft.net>
References: <20131014123726.GA17034@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpr@f6fbb.org, linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20131014123726.GA17034@mwanda>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 14 Oct 2013 15:46:15 +0300

> We overwrite the ->bitrate with the user supplied information on the
> next line.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
