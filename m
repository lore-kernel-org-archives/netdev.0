From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] calxedaxgmac: fixes for xgmac_set_rx_mode
Date: Wed, 02 Oct 2013 16:12:09 -0400 (EDT)
Message-ID: <20131002.161209.5649210659405467.davem@davemloft.net>
References: <1380571937-23439-1-git-send-email-robherring2@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rob.herring@calxeda.com
To: robherring2@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380571937-23439-1-git-send-email-robherring2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <robherring2@gmail.com>
Date: Mon, 30 Sep 2013 15:12:14 -0500

> This is a couple of fixes related to xgmac_set_rx_mode. The changes are
> necessary for "bridge fdb add" to work correctly.

Series applied, thanks Rob.
