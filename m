From: David Miller <davem@davemloft.net>
Subject: Re: RFC v1: sysctl: add sysctl header cookie, share tables between
 nets
Date: Wed, 02 Mar 2011 17:06:44 -0800 (PST)
Message-ID: <20110302.170644.58413369.davem@davemloft.net>
References: <1298659961-23863-1-git-send-email-lucian.grijincu@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, ebiederm@xmission.com, tavi@cs.pub.ro,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: lucian.grijincu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298659961-23863-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Date: Fri, 25 Feb 2011 20:52:32 +0200

> This is a new approach to the "share sysctl tables" RFC series I
> posted earlier this month.

I do not disagree conceptually with these changes from a networking
perspective, but I am not a sysctl layer expert so I don't know if the
generic sysctl bits are a good idea or not.
