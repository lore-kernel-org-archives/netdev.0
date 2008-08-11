From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- RCU problem
Date: Mon, 11 Aug 2008 11:08:37 -0700
Message-ID: <86802c440808111108h3a14d98dwae52d1b1b8c5c52f@mail.gmail.com>
References: <49829.86808.qm@web82105.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ingo Molnar" <mingo@elte.hu>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"Peter Zijlstra" <peterz@infradead.org>,
	linux-kernel@vger.kernel.org,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: "David Witbrodt" <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.224]:29742 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753347AbYHKSIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 14:08:39 -0400
Received: by wr-out-0506.google.com with SMTP id 69so1483567wri.5
        for <netdev@vger.kernel.org>; Mon, 11 Aug 2008 11:08:38 -0700 (PDT)
In-Reply-To: <49829.86808.qm@web82105.mail.mud.yahoo.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2008 at 11:01 AM, David Witbrodt <dawitbro@sbcglobal.net> wrote:
>
>
> Thanks for the reply.  Let me address these out of order (cutting
> your post):
>
>> David, it would be nice to check whether tip/master still locks up for
>> you:
>>
>>     http://people.redhat.com/mingo/tip.git/README
>>
>> just to make sure no pending fix resolves your issue. (the bug is
>> probably still present, but might be worth checking nevertheless.)
>
> Just to recap (not sure if you saw the earlier posts in the thread, going
> back to Monday a week ago):
>
> - kernel 2.6.25 worked for me without error

does hpet work at 2.6.25? or it is not enabled by default for the
famous chipset?

YH
