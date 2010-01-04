From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] niu: timeout ignored in tcam_wait_bit()
Date: Sun, 03 Jan 2010 21:43:24 -0800 (PST)
Message-ID: <20100103.214324.252834689.davem@davemloft.net>
References: <4B376AF3.6090408@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753218Ab0ADFn0@vger.kernel.org>
In-Reply-To: <4B376AF3.6090408@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sun, 27 Dec 2009 15:10:59 +0100

> With `while (--limit > 0)' i reaches 0 after the loop, so upon timeout the
> error was not returned.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied.
