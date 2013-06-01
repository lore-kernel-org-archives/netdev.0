From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH v2 net 0/6] net/core, bonding: dev_uc_sync fixes, bonding update
Date: Sat, 1 Jun 2013 20:00:04 +0300
Message-ID: <CAJZOPZJ8onm0NhKMbQFmZFcoVzVZ=okikLzk=8rWrDvYGrL1Cw@mail.gmail.com>
References: <1370037451-29466-1-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f46.google.com ([209.85.128.46]:65465 "EHLO
	mail-qe0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979Ab3FARAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jun 2013 13:00:05 -0400
Received: by mail-qe0-f46.google.com with SMTP id w7so745678qeb.33
        for <netdev@vger.kernel.org>; Sat, 01 Jun 2013 10:00:05 -0700 (PDT)
In-Reply-To: <1370037451-29466-1-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 1, 2013 at 12:57 AM, Jay Vosburgh <fubar@us.ibm.com> wrote:
> This patch set includes 6 patches: four fixes to the dev_mc_sync /  dev_mc_unsync
>system; and two patches to bonding, one to utilize the sync / unsync functions

does anything here needs to go into -stable, or it was all introduced
in 3.10-rc1?
