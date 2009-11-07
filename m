From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] NET: cassini, fix lock imbalance
Date: Fri, 06 Nov 2009 20:26:44 -0800 (PST)
Message-ID: <20091106.202644.38012917.davem@davemloft.net>
References: <1257498869-4374-1-git-send-email-jirislaby@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jirislaby@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760226AbZKGE0V@vger.kernel.org>
In-Reply-To: <1257498869-4374-1-git-send-email-jirislaby@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Slaby <jirislaby@gmail.com>
Date: Fri,  6 Nov 2009 10:14:29 +0100

> Stanse found that one error path in cas_open omits to unlock pm_mutex.
> Fix that.
> 
> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>

Applied to net-2.6
