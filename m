From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute2: ip: add udp_csum, udp6_csum_tx, udp6_csum_rx
 control flags to ip l2tp add tunnel
Date: Fri, 22 Jul 2016 15:27:10 -0700
Message-ID: <20160722152710.399d0d30@xeon-e3>
References: <F9EDF03C-EBC6-468D-A917-ED5CF232C203@tuna.tsinghua.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org,
	=?UTF-8?B?546L6YKI?= <shankerwangmiao@gmail.com>
To: Shanker Wang <miao.wang@tuna.tsinghua.edu.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33075 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751230AbcGVW0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2016 18:26:55 -0400
Received: by mail-pf0-f172.google.com with SMTP id y134so45172133pfg.0
        for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 15:26:55 -0700 (PDT)
In-Reply-To: <F9EDF03C-EBC6-468D-A917-ED5CF232C203@tuna.tsinghua.edu.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Jul 2016 18:59:10 +0800
Shanker Wang <miao.wang@tuna.tsinghua.edu.cn> wrote:

> Three options are added for the user to control
> whether the checksum is enabled
> 
> Signed-off-by: Miao Wang <miao.wang@tuna.tsinghua.edu.cn>

Applied.
I changed the subject (commit summary) to be shorter.
Many tools complain about long subject lines.
