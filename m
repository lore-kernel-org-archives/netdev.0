From: Aaron Conole <aconole@bytheb.org>
Subject: Re: [PATCH net] af_unix: return data from multiple SKBs on recv() with MSG_PEEK flag
Date: Sat, 19 Sep 2015 21:55:40 -0400
Message-ID: <87bncxg8gz.fsf@bytheb.org>
References: <f7tvbb7zpbf.fsf@aconole.bos.csb>
	<55FD9A0E.1090804@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:36054 "EHLO
	mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753214AbbITBzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 21:55:43 -0400
Received: by qkcf65 with SMTP id f65so33278787qkc.3
        for <netdev@vger.kernel.org>; Sat, 19 Sep 2015 18:55:42 -0700 (PDT)
In-Reply-To: <55FD9A0E.1090804@cogentembedded.com> (Sergei Shtylyov's message
	of "Sat, 19 Sep 2015 20:23:26 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> writes:

> Hello.
> ...
>    Your patch doesn't comply to the Linux CodingStyle.
> ...

I'll fix and post v2 - apologies for messing up with that check.

-Aaron
