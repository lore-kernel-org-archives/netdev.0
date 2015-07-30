From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/phy: micrel: Reenable interrupts during resume
Date: Thu, 30 Jul 2015 10:00:34 -0700 (PDT)
Message-ID: <20150730.100034.1983500409184401997.davem@davemloft.net>
References: <1438269348-8725-1-git-send-email-nathan.sullivan@ni.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nathan.sullivan@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438269348-8725-1-git-send-email-nathan.sullivan@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nathan Sullivan <nathan.sullivan@ni.com>
Date: Thu, 30 Jul 2015 10:15:48 -0500

> Changes for V2: Actually make sure it compiles this time.

If V1 didn't compile, even for you, then I have a big problem.

And that problem is that you didn't test this change at all.
