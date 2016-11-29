From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute] ip: support UID range routing.
Date: Tue, 29 Nov 2016 12:30:28 -0800
Message-ID: <20161129123028.47e4a4d5@samsung9>
References: <1478449611-139263-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:32904 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751991AbcK2Uac (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 15:30:32 -0500
Received: by mail-pg0-f49.google.com with SMTP id 3so73144029pgd.0
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 12:30:31 -0800 (PST)
In-Reply-To: <1478449611-139263-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  7 Nov 2016 01:26:51 +0900
Lorenzo Colitti <lorenzo@google.com> wrote:

> - Support adding, deleting and showing IP rules with UID ranges.
> - Support querying per-UID routes via "ip route get uid <UID>".
> 
> UID range routing was added to net-next in 4fb7450683 ("Merge
> branch 'uid-routing'")
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Applied to net-next, will be pushed shortly.
