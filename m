From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] enable hires timer to timeout datagram socket
Date: Tue, 22 Aug 2017 21:30:30 -0700 (PDT)
Message-ID: <20170822.213030.1848111782253505433.davem@davemloft.net>
References: <1503447027-44399-1-git-send-email-vallish@amazon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shuah@kernel.org, richardcochran@gmail.com,
        xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, eduval@amazon.com,
        anchalag@amazon.com
To: vallish@amazon.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503447027-44399-1-git-send-email-vallish@amazon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vallish Vaidyeshwara <vallish@amazon.com>
Date: Wed, 23 Aug 2017 00:10:25 +0000

> I am submitting 2 patch series to enable hires timer to timeout
> datagram sockets (AF_UNIX & AF_INET domain) and test code to test
> timeout accuracy on these sockets.

This is not reasonable.

If you want high resolution events with real guarantees, please use
the kernel interfaces which provide this as explained to you as
feedback by other reviewers.

I'm not applying this, sorry.
