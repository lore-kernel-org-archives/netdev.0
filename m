From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 5/5] ISDN-CAPI: Delete unnecessary braces
Date: Mon, 26 Sep 2016 21:55:42 +0200
Message-ID: <1474919742.4539.11.camel@tiscali.nl>
References: <be07f84d-fc84-e47d-207e-aedd8c960151@users.sourceforge.net>
         <06e7637c-f682-bfa2-82b6-47d071bd58c4@users.sourceforge.net>
         <52dd5000-2bda-a1b6-aa97-1868e1193d35@cogentembedded.com>
         <727b14d4-7a3b-9de8-25d9-c3bf212f7c44@users.sourceforge.net>
         <1474881642.1846.14.camel@tiscali.nl>
         <e2f45ffb-9440-19c6-b7ce-0894dcd14879@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb3-smtp-cloud2.xs4all.net ([194.109.24.29]:40615 "EHLO
        lb3-smtp-cloud2.xs4all.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1034762AbcIZTzr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 15:55:47 -0400
In-Reply-To: <e2f45ffb-9440-19c6-b7ce-0894dcd14879@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-09-26 at 14:52 +0200, SF Markus Elfring wrote:
> Would it eventually make sense to move this "if" (behind an "else")
> to a separate line and increase the indentation for the corresponding
> code one level then?

No.


Paul Bolle
