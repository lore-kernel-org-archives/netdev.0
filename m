From: Michal Kazior <michal.kazior@tieto.com>
Subject: Re: codel: split into multiple files
Date: Tue, 26 Apr 2016 08:30:18 +0200
Message-ID: <CA+BoTQn2h8XQ5PwTm4Zy2-6JZs-muW2FmA0kVWf9OYCYgQ3T2g@mail.gmail.com>
References: <CA+icZUWrRbBJM3q7SzRSc2znAXZHr1JdXHD2j2POKvDin4=CZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: sedat.dilek@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37438 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195AbcDZGaU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 02:30:20 -0400
Received: by mail-wm0-f52.google.com with SMTP id n3so15859729wmn.0
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 23:30:19 -0700 (PDT)
In-Reply-To: <CA+icZUWrRbBJM3q7SzRSc2znAXZHr1JdXHD2j2POKvDin4=CZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26 April 2016 at 08:09, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> Hi,
>
> I had a very quick view on net-next.git#master (up to commit
> fab7b629a82da1b59620470d13152aff975239f6).
>
> Commit in [1] aka "codel: split into multiple files" removed codel.h
> but [2] and [3] have relicts to it.
> Forgot to remove?

codel.h was not removed. diffstat for codel.h is all red which I
presume is why you thought of it as removed, see:

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/tree/inc=
lude/net/codel.h?id=3Dd068ca2ae2e614b9a418fb3b5f1fd4cf996ff032


Micha=C5=82
