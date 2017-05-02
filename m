From: Aaron Conole <aconole@bytheb.org>
Subject: Re: those bpf binutils testsuite failures..
Date: Tue, 02 May 2017 12:05:37 -0400
Message-ID: <f7t60hjb5wu.fsf@redhat.com>
References: <20170501.224542.1972350718369704991.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33174 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdEBQFm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 12:05:42 -0400
Received: by mail-qt0-f196.google.com with SMTP id c45so20941592qtb.0
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 09:05:42 -0700 (PDT)
In-Reply-To: <20170501.224542.1972350718369704991.davem@davemloft.net> (David
        Miller's message of "Mon, 01 May 2017 22:45:42 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> I wonder if whatever tool you used to get rid of trailing whitespace
> did so in the testsuite foo.d files too?  That definitely is
> undesirable :-)

Most likely I was being too clever by half.  I'll make sure I omit the
.d files from scanning.
