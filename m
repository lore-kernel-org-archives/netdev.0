From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: micrel: Reenable interrupts during resume for
 ksz9031
Date: Tue, 23 Aug 2016 16:57:58 -0700 (PDT)
Message-ID: <20160823.165758.445689176745011634.davem@davemloft.net>
References: <1471899436-56626-1-git-send-email-xander.huff@ni.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, brad.mouring@ni.com,
        nathan.sullivan@ni.com
To: xander.huff@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471899436-56626-1-git-send-email-xander.huff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xander Huff <xander.huff@ni.com>
Date: Mon, 22 Aug 2016 15:57:16 -0500

> Like the ksz8081, the ksz9031 has the behavior where it will clear the
> interrupt enable bits when leaving power down. This takes advantage of the
> solution provided by f5aba91.
> 
> Signed-off-by: Xander Huff <xander.huff@ni.com>
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>

Applied.
