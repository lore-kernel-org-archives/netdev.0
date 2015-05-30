From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Recurring trace from tcp_fragment()
Date: Sat, 30 May 2015 19:08:06 -0400
Message-ID: <CADVnQymCSGyyOqdO2HOap+_6zsfy99-3CbgxnQTfGakRYNoteQ@mail.gmail.com>
References: <CFCC0DCC-4080-4195-9BA9-0860D9701805@fastly.com>
	<CADVnQyngTDVYMhmQq=pjS3LrdQ+HXyizujiOkmgXxTjQ0QKH8A@mail.gmail.com>
	<5E30A40E-EC6C-4D37-AB49-04BF40EEFBFC@fastly.com>
	<CADVnQy=rwKG_ddduixcee1D4HaaSBBk=X=2Htmdow0k6Cbxhzg@mail.gmail.com>
	<904FADEB-C1EB-4384-BA47-0EB0273AFB71@fastly.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Grant Zhang <gzhang@fastly.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:34109 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbbE3XIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2015 19:08:07 -0400
Received: by oifu123 with SMTP id u123so79404796oif.1
        for <netdev@vger.kernel.org>; Sat, 30 May 2015 16:08:06 -0700 (PDT)
In-Reply-To: <904FADEB-C1EB-4384-BA47-0EB0273AFB71@fastly.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 30, 2015 at 2:52 PM, Grant Zhang <gzhang@fastly.com> wrote:
> Thank you Neal. Most likely I will test the patch on Monday and report
> back the result.
>
> As for the TcpExtTCPSACKReneging counter, attached is the captured
> counter value on a 1-second interval for 10 minutes.

OK, great. Those TcpExtTCPSACKReneging values look consistent with the
theory underlying the patch, so that's a good sign.

Thanks!

neal
