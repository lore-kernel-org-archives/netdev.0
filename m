From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 00/10] constify net attribute_group structures.
Date: Tue, 18 Jul 2017 12:05:19 -0700 (PDT)
Message-ID: <20170718.120519.1486226559473488270.davem@davemloft.net>
References: <1500371025-14614-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: arvind.yadav.cs@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1500371025-14614-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Tue, 18 Jul 2017 15:13:44 +0530

> attribute_group are not supposed to change at runtime. All functions
> working with attribute_group provided by <linux/sysfs.h> work with const
> attribute_group. So mark the non-const structs as const.

Series applied, thanks.
