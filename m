From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 00/10] Constify attribute_group structures
Date: Tue, 11 Jul 2017 10:34:46 -0700 (PDT)
Message-ID: <20170711.103446.1239391217884819019.davem@davemloft.net>
References: <1499757762-24610-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: arvind.yadav.cs@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499757762-24610-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Tue, 11 Jul 2017 12:52:41 +0530

> attribute_groups are not supposed to change at runtime. So mark the
> non-const structs as const.

Please resubmit this when net-next is open again:

	http://vger.kernel.org/~davem/net-next.html

Thank you.
