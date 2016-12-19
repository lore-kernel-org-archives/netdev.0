From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: Linux support for 802.1AS-Rev.
Date: Mon, 19 Dec 2016 16:06:02 +0100
Message-ID: <20161219150602.GA14051@localhost.localdomain>
References: <CA+tSgV+DWJHJ4LBHTyX4bzwLyCq+3=4nOF+eLjWwFPyYfP6FsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Praveen Bajantri <pibbgm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34827 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932402AbcLSPGH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 10:06:07 -0500
Received: by mail-wm0-f65.google.com with SMTP id a20so19187763wme.2
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2016 07:06:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CA+tSgV+DWJHJ4LBHTyX4bzwLyCq+3=4nOF+eLjWwFPyYfP6FsQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 19, 2016 at 03:50:08PM +0530, Praveen Bajantri wrote:
> I am new to Linux networking and had doubt related to support for
> 802.1AS-Rev. Please point me to appropriate forum/mailing list If this
> is not a right place.

This list is for kernel related issues.  The mailing lists for the
user space gPTP stack are at:

   https://lists.sourceforge.net/lists/listinfo/linuxptp-users
   https://lists.sourceforge.net/lists/listinfo/linuxptp-devel

> Does Linux support 802.1AS-Rev ? Is there any application which can be
> used to test this feature ?

Looking at

   http://www.ieee802.org/1/pages/802.1AS-rev.html

this standard hasn't even been published, and the drafts are locked
away for committee's eyes only.

So how on earth do you expect us to support it?

Thanks,
Richard
