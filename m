From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ethoc: clear only pending irqs
Date: Sun, 18 Oct 2009 21:24:42 -0700 (PDT)
Message-ID: <20091018.212442.259583006.davem@davemloft.net>
References: <1254961003-2453-1-git-send-email-thomas@wytron.com.tw>
	<1254961003-2453-2-git-send-email-thomas@wytron.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thierry.reding@avionic-design.de,
	nios2-dev@sopc.et.ntust.edu.tw, linux-kernel@vger.kernel.org
To: thomas@wytron.com.tw
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752283AbZJSEYW@vger.kernel.org>
In-Reply-To: <1254961003-2453-2-git-send-email-thomas@wytron.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Chou <thomas@wytron.com.tw>
Date: Thu,  8 Oct 2009 08:16:43 +0800

> This patch fixed the problem of dropped packets due to lost of
> interrupt requests. We should only clear what was pending at the
> moment we read the irq source reg.
> 
> Signed-off-by: Thomas Chou <thomas@wytron.com.tw>

Applied.
