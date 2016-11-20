From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 00/18] Update ENA driver to version 1.1.2
Date: Sun, 20 Nov 2016 10:24:22 -0500 (EST)
Message-ID: <20161120.102422.733701532971988272.davem@davemloft.net>
References: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        dwmw@amazon.com, zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: netanel@annapurnalabs.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Netanel Belgazal <netanel@annapurnalabs.com>
Date: Sun, 20 Nov 2016 10:45:29 +0200

> Update Amazon's Elastic Network Adapter (ENA) driver version from 1.0.2 to 1.1.2

This is insufficient.

You must explain what this patch series is doing, how it is doing it,
and why it is doing it that way.

This is the message that people will look at to learn what is
contained in this series of patches, and they might be looking for
keywords or explanations as to why a decision was made to add a
feature, turn a feature off, or make some other important high level
change to the driver.
