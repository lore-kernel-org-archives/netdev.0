From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ethernet driver: dm9000: davicom: Upgrade the
 driver to suit for all DM9000 series chips
Date: Mon, 25 Mar 2013 13:09:24 -0400 (EDT)
Message-ID: <20130325.130924.1771800578429290181.davem@davemloft.net>
References: <1364198682-1589-1-git-send-email-josright123@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wfp5p@virginia.edu, matthew@mattleach.net,
	gregkh@linuxfoundation.org, joseph_chang@davicom.com.tw,
	jiri@resnulli.us, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: josright123@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364198682-1589-1-git-send-email-josright123@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joseph CHANG <josright123@gmail.com>
Date: Mon, 25 Mar 2013 16:04:42 +0800

>  #define CARDNAME	"dm9000"
> -#define DRV_VERSION	"1.31"
> +/* [KERN-ADD-1](upgrade) */
> +#define DRV_VERSION	"1.39"
 ...
> +			/* [KERN-ADD-2] */

These kinds of comments are absolutely inapproprate.
