From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] constify net platform_device_id
Date: Sun, 13 Aug 2017 20:12:58 -0700 (PDT)
Message-ID: <20170813.201258.1936266760483908698.davem@davemloft.net>
References: <1502622705-11169-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, mkl@pengutronix.de, madalin.bucur@nxp.com,
        sergei.shtylyov@cogentembedded.com, grygorii.strashko@ti.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-can@vger.kernel.org
To: arvind.yadav.cs@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502622705-11169-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Sun, 13 Aug 2017 16:41:44 +0530

> platform_device_id are not supposed to change at runtime. All functions
> working with platform_device_id provided by <linux/platform_device.h>
> work with const platform_device_id. So mark the non-const structs as const.

Series applied, thanks.
