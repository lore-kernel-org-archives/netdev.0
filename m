From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 3/5] cxgb4: add dcb info node in debugfs
Date: Mon, 21 Dec 2015 09:33:22 +0200
Message-ID: <CAJ3xEMjctGauyRjCKLV+wACkzDC5xF8J9khdhCm+YZXuEafU5Q@mail.gmail.com>
References: <1450682170-7106-1-git-send-email-hariprasad@chelsio.com>
	<1450682170-7106-4-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, leedom@chelsio.com,
	nirranjan@chelsio.com, John Fastabend <john.r.fastabend@intel.com>
To: Hariprasad Shenai <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:33380 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835AbbLUHdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 02:33:23 -0500
Received: by mail-ig0-f177.google.com with SMTP id mv3so26088343igc.0
        for <netdev@vger.kernel.org>; Sun, 20 Dec 2015 23:33:23 -0800 (PST)
In-Reply-To: <1450682170-7106-4-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 21, 2015 at 9:16 AM, Hariprasad Shenai
<hariprasad@chelsio.com> wrote:
> Add new /sys/kernel/debug/cxgb4/*/dcb_info node to dump out
> various Data Center Bridging information.

why? what's wrong with using the lldp tool for that purpose?
