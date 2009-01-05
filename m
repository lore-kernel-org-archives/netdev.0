From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/3] cls_cgroup: clean up Kconfig
Date: Mon, 5 Jan 2009 17:12:08 +0100
Message-ID: <20090105161208.GO20815@postel.suug.ch>
References: <49584AA5.9030509@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:52873 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750823AbZAEQLt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2009 11:11:49 -0500
Content-Disposition: inline
In-Reply-To: <49584AA5.9030509@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Li Zefan <lizf@cn.fujitsu.com> 2008-12-29 11:57
> cls_cgroup can't be compiled as a module, since it's not supported by
> cgroup.

Good catch, thanks.

Acked-by: Thomas Graf <tgraf@suug.ch>
