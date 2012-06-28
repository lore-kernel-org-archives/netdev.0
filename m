From: "George B." <georgeb@gmail.com>
Subject: Re: Sending Packet Much Larger Than MSS
Date: Thu, 28 Jun 2012 11:28:07 -0700
Message-ID: <CAJ2iOjQ0gjPb4o8hMSpEbRc4RVu3cfxUJ=m5hhad3jLbGE-r7A@mail.gmail.com>
References: <CAJ2iOjQGrnhG7L1jDAXybJiG7O5OpnaDzw5UBEuN2kEWXYGUnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:51668 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752842Ab2F1S2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 14:28:08 -0400
Received: by werb14 with SMTP id b14so616329wer.19
        for <netdev@vger.kernel.org>; Thu, 28 Jun 2012 11:28:07 -0700 (PDT)
In-Reply-To: <CAJ2iOjQGrnhG7L1jDAXybJiG7O5OpnaDzw5UBEuN2kEWXYGUnQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 28, 2012 at 10:21 AM, George B. <georgeb@gmail.com> wrote:

> Is this a known issue with that kernel?
>
> Thanks.
>
> George

Ok, I am probably seeing GSO/TSO here.  Let me turn that off and try
again.  Sorry to bother.

George
