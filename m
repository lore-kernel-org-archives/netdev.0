From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: document accel_priv parameter for
 __dev_queue_xmit()
Date: Sun, 19 Jan 2014 19:49:50 -0800 (PST)
Message-ID: <20140119.194950.1783573143714328209.davem@davemloft.net>
References: <1390188313-9275-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390188313-9275-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Mon, 20 Jan 2014 11:25:13 +0800

> To silent "make htmldocs" warning.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

This is certainly not such a catastrophic error that it should be
targetted at the 'net' tree.
