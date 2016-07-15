From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8152: add MODULE_VERSION
Date: Fri, 15 Jul 2016 14:25:55 -0700 (PDT)
Message-ID: <20160715.142555.1193736550101992811.davem@davemloft.net>
References: <1468520836-9060-1-git-send-email-grundler@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, peter@lekensteyn.nl, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: grundler@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468520836-9060-1-git-send-email-grundler@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Grundler <grundler@chromium.org>
Date: Thu, 14 Jul 2016 11:27:16 -0700

> ethtool -i provides a driver version that is hard coded.
> Export the same value via "modinfo".
> 
> Signed-off-by: Grant Grundler <grundler@chromium.org>

Applied.
