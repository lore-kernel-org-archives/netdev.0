From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v6 6/6] samples/bpf: add userspace example for
 prohibiting sockets
Date: Mon, 5 Dec 2016 07:31:46 -0700
Message-ID: <9b6a178e-929a-59c7-78e8-cf9ee1062047@cumulusnetworks.com>
References: <1480529810-25850-1-git-send-email-dsa@cumulusnetworks.com>
 <1480529810-25850-7-git-send-email-dsa@cumulusnetworks.com>
 <20161201055953.GB42375@ast-mbp.thefacebook.com>
 <4afe76e2-d1be-4810-0db7-859bcd5c89f3@cumulusnetworks.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0234BBD@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "daniel@zonque.org" <daniel@zonque.org>, "ast@fb.com" <ast@fb.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "maheshb@google.com" <maheshb@google.com>,
        "tgraf@suug.ch" <tgraf@suug.ch>
To: David Laight <David.Laight@ACULAB.COM>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:34219 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750951AbcLEObt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 09:31:49 -0500
Received: by mail-pg0-f45.google.com with SMTP id x23so137381887pgx.1
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 06:31:49 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0234BBD@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/5/16 3:51 AM, David Laight wrote:
> You can at least improve the comment.

I fixed the header files for v7.
