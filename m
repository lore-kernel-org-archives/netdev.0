From: Jes Sorensen <Jes.Sorensen@redhat.com>
Subject: Re: [PATCH] realtek: rtl8xxxu: Use const init arrays
Date: Sat, 01 Oct 2016 19:20:12 -0400
Message-ID: <wrfjh98v4pxv.fsf@redhat.com>
References: <459bf15427d92cd052fb2fe080438fd97a8a6cd8.1475343483.git.joe@perches.com>
        <wrfj37kf6gvd.fsf@redhat.com> <1475352058.1996.1.camel@perches.com>
        <wrfjponj4xpq.fsf@redhat.com> <1475356122.1996.6.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1082 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751161AbcJAXUP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 1 Oct 2016 19:20:15 -0400
In-Reply-To: <1475356122.1996.6.camel@perches.com> (Joe Perches's message of
        "Sat, 01 Oct 2016 14:08:42 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches <joe@perches.com> writes:
> On Sat, 2016-10-01 at 16:32 -0400, Jes Sorensen wrote:
>> Your output shows it moving to the text segment - if it's in a different
>> segment, eg. rodata, you should use output demonstrating that to justify
>> the change.
>
> For size, rodata _is_ text

Well then maybe use something which provides accurate data.

Jes
