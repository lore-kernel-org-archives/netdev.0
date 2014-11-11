From: Cong Wang <cwang@twopensource.com>
Subject: Re: Tracking errors in netdevice (and other?) notifiers
Date: Tue, 11 Nov 2014 13:42:35 -0800
Message-ID: <CAHA+R7NkDhBTxUhitE6Y-WrqEQmxhgUmXvMuD4qZOXLryV-JDg@mail.gmail.com>
References: <CACna6ryUOhQSyjiqKwpOZPPRKC42ufB1aSqAwOrMdTJDnqiD-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:41399 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752428AbaKKVmi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 16:42:38 -0500
Received: by mail-qa0-f49.google.com with SMTP id i13so7507345qae.8
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 13:42:35 -0800 (PST)
In-Reply-To: <CACna6ryUOhQSyjiqKwpOZPPRKC42ufB1aSqAwOrMdTJDnqiD-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2014 at 9:39 AM, Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.=
com> wrote:
>
> Is there some trick to do that? To track notifiers and find a code
> responsible for the chain error?
>

trace-cmd may help you to find the real call back.
