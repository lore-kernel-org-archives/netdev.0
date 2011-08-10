From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] gianfar: reduce stack usage in gianfar_ethtool.c
Date: Tue, 09 Aug 2011 21:07:17 -0700
Message-ID: <1312949237.11924.58.camel@Joe-Laptop>
References: <1312943399-14435-1-git-send-email-wangshaoyan.pt@taobao.com>
	 <1312943316.11924.54.camel@Joe-Laptop>
	 <CANxBZFpm-at-FgNdP9nefwFfpzHmTMMsPSNWKJuT2R6TazhsYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, Wang Shaoyan <wangshaoyan.pt@taobao.com>
To: Wang Shaoyan <stufever@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANxBZFpm-at-FgNdP9nefwFfpzHmTMMsPSNWKJuT2R6TazhsYQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-08-10 at 11:50 +0800, Wang Shaoyan wrote:
> Yes, I want to test, but I can't open CONFIG_GIANFAR, because I can't
> find FSL_SOC, am i miss something?

A cross compiler for powerpc?

You can get one from here:
ftp://ftp.kernel.org/pub/tools/crosstool/files/bin/i686/

Pick an appropriate gcc for you.

Then read the process docs in Documentation/development-process
or google linux cross compiling.
