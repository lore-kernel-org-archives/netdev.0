From: Bastien Nocera <hadess@hadess.net>
Subject: Re: [PATCH 00/22] staging: rtl87232bs: Fix errors and warnings
 detected by Smatch
Date: Sun, 09 Apr 2017 17:29:23 +0200
Message-ID: <1491751763.10783.22.camel@hadess.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        hdegoede@redhat.com, jes.sorensen@gmail.com
To: Larry Finger <Larry.Finger@lwfinger.net>,
        gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:48293 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752360AbdDIP3a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Apr 2017 11:29:30 -0400
Received: from relay8-d.mail.gandi.net (relay8-d.mail.gandi.net [217.70.183.201])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 59D9D48640E
        for <netdev@vger.kernel.org>; Sun,  9 Apr 2017 17:29:29 +0200 (CEST)
In-Reply-To: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-04-08 at 11:07 -0500, Larry Finger wrote:
> A number of routines have indenting, off by one, and possible usage
> while null warnings or errors listed by Smatch. This set of patches
> fix all but one of these, and it is in code that will be removed in a
> subsequent patch.
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>

Feel free to add:
Reviewed-by: Bastien Nocera <hadess@hadess.net>
for all the patches I didn't directly comment on.

Cheers
