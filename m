From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] tcp: Add a TCP_FASTOPEN socket option to get a max
 backlog on its listner
Date: Sun, 20 Apr 2014 18:19:23 -0400 (EDT)
Message-ID: <20140420.181923.621422833689356210.davem@davemloft.net>
References: <87a9bljl7m.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ncardwell@google.com,
	netdev@vger.kernel.org, ycheng@google.com, edumazet@google.com
To: nakayamakenjiro@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87a9bljl7m.fsf@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kenjiro Nakayama <nakayamakenjiro@gmail.com>
Date: Thu, 17 Apr 2014 01:25:01 +0900

> This patch adds a TCP_FASTOPEN socket option to get a max backlog on its
> listener to getsockopt().
> 
> Signed-off-by: Kenjiro Nakayama <nakayamakenjiro@gmail.com>

Applied.
