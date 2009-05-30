From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] networking: Add write/clear capability to /proc/net/dev
Date: Fri, 29 May 2009 20:49:54 -0700 (PDT)
Message-ID: <20090529.204954.176335535.davem@davemloft.net>
References: <4A207D52.9000407@gedanken.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mehaf@gedanken.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758841AbZE3DuA@vger.kernel.org>
In-Reply-To: <4A207D52.9000407@gedanken.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Mehaffey <mehaf@gedanken.com>
Date: Fri, 29 May 2009 17:26:58 -0700

> There is currently no way to reset networking statistics other than to
> rmmod the interface and reinstall it.

This has been NAK'd a thousand times in the past.  We're not
adding a change like this, sorry.

Do it in userspace or similar.
