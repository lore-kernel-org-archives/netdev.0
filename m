From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] X25: Fix x25_create errors for bad protocol and
 ENOBUFS
Date: Wed, 10 Feb 2010 17:54:13 -0800 (PST)
Message-ID: <20100210.175413.199161275.davem@davemloft.net>
References: <d45a3acc1002061516s3b3eab26tc2a9339613684e6f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: andrew.hendry@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d45a3acc1002061516s3b3eab26tc2a9339613684e6f@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: andrew hendry <andrew.hendry@gmail.com>
Date: Sun, 7 Feb 2010 10:16:59 +1100

> alloc_socket failures should return -ENOBUFS
> a bad protocol should return -EINVAL
> 
> Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

Both of your patches were corrupted by your email client, so they
will not apply properly.

For example, long lines were chopped up into multiple lines.

See linux/Documentation/email-clients.txt for tips.

Please fix this up and resubmit your patches.
