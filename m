From: Amir Vadai <amir@vadai.me>
Subject: Re: [Patch net 3/5] net_sched: fix a typo in tc_for_each_action()
Date: Tue, 9 Aug 2016 09:37:25 +0300
Message-ID: <20160809063725.GA7102@office.localdomain>
References: <1470689209-17682-1-git-send-email-xiyou.wangcong@gmail.com>
 <1470689209-17682-4-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34687 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752171AbcHIGh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 02:37:29 -0400
Received: by mail-wm0-f65.google.com with SMTP id q128so1165345wma.1
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 23:37:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1470689209-17682-4-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 08, 2016 at 01:46:47PM -0700, Cong Wang wrote:
> It is harmless because all users pass 'a' to this macro.
> 
> Fixes: 00175aec941e ("net/sched: Macro instead of CONFIG_NET_CLS_ACT ifdef")
> Cc: Amir Vadai <amir@vadai.me>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---

Acked-by: Amir Vadai <amir@vadai.me>

Thanks Cong.
