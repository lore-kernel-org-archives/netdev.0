From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] constify net eisa_device_id
Date: Sat, 19 Aug 2017 17:13:56 -0700 (PDT)
Message-ID: <20170819.171356.1494785022831637936.davem@davemloft.net>
References: <1503125503-15075-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tremyfr@gmail.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: arvind.yadav.cs@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503125503-15075-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Sat, 19 Aug 2017 12:21:42 +0530

> eisa_device_id are not supposed to change at runtime. All functions
> working with eisa_device_id provided by <linux/eisa.h> work with
> const eisa_device_id. So mark the non-const structs as const.

Series applied, thanks.
