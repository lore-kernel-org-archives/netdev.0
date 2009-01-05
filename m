From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] cls_cgroup: clean up for cgroup part
Date: Mon, 5 Jan 2009 17:11:48 +0100
Message-ID: <20090105161148.GN20815@postel.suug.ch>
References: <49584AA2.4010506@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:52868 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750909AbZAEQL3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2009 11:11:29 -0500
Content-Disposition: inline
In-Reply-To: <49584AA2.4010506@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Li Zefan <lizf@cn.fujitsu.com> 2008-12-29 11:57
> - It's better to use container_of() instead of casting cgroup_subsys_state *
>   to cgroup_cls_state *.
> - Add helper function task_cls_state().
> - Rename net_cls_state() to cgrp_cls_state().

A bit pointless but does not hurt anyone.

Acked-by: Thomas Graf <tgraf@suug.ch>
