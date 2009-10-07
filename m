From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethoc: limit the number of buffers to 128
Date: Wed, 07 Oct 2009 03:42:22 -0700 (PDT)
Message-ID: <20091007.034222.157492766.davem@davemloft.net>
References: <1254835525-2529-1-git-send-email-thomas@wytron.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thierry.reding@avionic-design.de,
	nios2-dev@sopc.et.ntust.edu.tw, linux-kernel@vger.kernel.org
To: thomas@wytron.com.tw
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758859AbZJGKm2@vger.kernel.org>
In-Reply-To: <1254835525-2529-1-git-send-email-thomas@wytron.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Chou <thomas@wytron.com.tw>
Date: Tue,  6 Oct 2009 21:25:25 +0800

> Only 128 buffer descriptors are supported in the core. Limit the
> number in case we have more memory.
> 
> Signed-off-by: Thomas Chou <thomas@wytron.com.tw>

Applied.
