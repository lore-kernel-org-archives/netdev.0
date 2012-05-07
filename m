From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pch_gbe: Adding read memory barriers
Date: Mon, 07 May 2012 13:44:51 -0400 (EDT)
Message-ID: <20120507.134451.951672483281209005.davem@davemloft.net>
References: <4FA808E3.1030908@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, tshimizu818@gmail.com
To: erwanaliasr1@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FA808E3.1030908@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Erwan Velu <erwanaliasr1@gmail.com>
Date: Mon, 07 May 2012 19:39:47 +0200

> Please find attached

First of all, for a patch which is not accepted yet you do not
CC: stable.

Second of all, do not put text in the main body of your email which is
unrelated to the patch and should not end up in the commit message.

Instead, post your patch to the appropriate primary mailing lists,
and if it's accepted it can then be submitted to -stable at some
later time.

Your patch posting email should be composed purely of the commit
log message in the message body, followed by the actual patch.

Otherwise the maintainer that applies your patch has to edit out
all of this other flowery text that is unrelated to the commit
and that makes more work for them.
