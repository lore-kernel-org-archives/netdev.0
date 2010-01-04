From: David Miller <davem@davemloft.net>
Subject: Re: [patch] hamradio: avoid null deref v3
Date: Sun, 03 Jan 2010 21:44:24 -0800 (PST)
Message-ID: <20100103.214424.144353990.davem@davemloft.net>
References: <20091226123812.GB6075@bicker>
	<20091226.201729.15225529.davem@davemloft.net>
	<20091228165455.GA17645@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: error27@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753271Ab0ADFo0@vger.kernel.org>
In-Reply-To: <20091228165455.GA17645@bicker>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <error27@gmail.com>
Date: Mon, 28 Dec 2009 18:54:55 +0200

> This should address the problems in version 1 (lazy) and version 2 (ugly).
> 
> Bump the stats on orig_dev not on the newly assigned NULL dev variable.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
