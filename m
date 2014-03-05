From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] Drivers:net:wireless:ti:wl1251: Fixed Sparse invalid
 assignment warning
Date: Wed, 5 Mar 2014 17:50:20 +0100
Message-ID: <20140305165020.GA17056@Nokia-N900>
References: <1393921132-15950-1-git-send-email-surendra.tux@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville@tuxdriver.com, pali.rohar@gmail.com,
	david.gnedt@davizone.at, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Surendra Patil <surendra.tux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1393921132-15950-1-git-send-email-surendra.tux@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue 2014-03-04 00:18:52, Surendra Patil wrote:
> Sparse warns about invalid assignment in
> drivers/net/wireless/ti/wl1251/cmd.c:451:42: warning: invalid assignment: |=
> drivers/net/wireless/ti/wl1251/cmd.c:451:42:    left side has type restricted __le16
> drivers/net/wireless/ti/wl1251/cmd.c:451:42:    right side has type int
> Hence type converted right side to __le16.
> 
> Signed-off-by: Surendra Patil <surendra.tux@gmail.com>

Acked-by: Pavel MMachek <pavel@ucw.cz>
