From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/1] tc: pass correct conversion specifier to
 print 'unsigned int' action index.
Date: Wed, 14 Dec 2016 19:30:46 -0800
Message-ID: <20161214193046.3e571722@xeon-e3>
References: <1481661076-28962-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:33451 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754916AbcLODat (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 22:30:49 -0500
Received: by mail-pg0-f41.google.com with SMTP id 3so15025323pgd.0
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 19:30:49 -0800 (PST)
In-Reply-To: <1481661076-28962-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Dec 2016 15:31:16 -0500
Roman Mashak <mrv@mojatatu.com> wrote:

> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied. There are lots of unsigned vs signed int things lurking in code.
