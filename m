From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: Fwd: [linux] [PATCH] ATH6KL: "Fix the byte alignment rule to avoid loss of bytes in a TCP segment" (#27)
Date: Thu, 28 Feb 2013 09:50:45 +0200
Message-ID: <87ehg0j2qy.fsf@kamboji.qca.qualcomm.com>
References: <torvalds/linux/pull/27@github.com>
	<CA+55aFxmE+hEm53f2gjFetNREW6J8X1GfpzeVxhHnECC-h6D7Q@mail.gmail.com>
	<20130227174207.GB2082@tuxdriver.com>
	<CABzs15BFOUWH=fMnerKW9-84PZKy5+2eN8XDhiCHTEHHjYf31w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	<linux-wireless@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	<ath6kl-devel@qca.qualcomm.com>
To: Myoungje Kim <mjei78@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabertooth02.qualcomm.com ([65.197.215.38]:13196 "EHLO
	sabertooth02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548Ab3B1Huw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 02:50:52 -0500
In-Reply-To: <CABzs15BFOUWH=fMnerKW9-84PZKy5+2eN8XDhiCHTEHHjYf31w@mail.gmail.com>
	(Myoungje Kim's message of "Thu, 28 Feb 2013 12:11:56 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Myoungje,

(adding ath6kl-devel)

Myoungje Kim <mjei78@gmail.com> writes:

> How I appreciate your e-mail about my trivial patch.
> I am very happy due to receiving your reply(even though 'CC' ^^;)
>
> You don't need to count the ways you hate GitHub pull requests, 
> now I knew that enough ^^.
> It was the only easy way I've thought to commit to the main tree.
> You already know that I am very beginner.
>
>
> I'm ashamed to say that I spent about 3 weeks to find and debug this issue.
> My patch looks so simple,
> but I don't want anyone to trouble spending or wasting their time like me
> due to this issue makes me suspect all of linux kernel TCP/IP stack and curl,
> wget, ftp client, user HTTP client, library, everything of my system.
> So it made me to make pull request through github I`ve ever known as the way to
> commit.
>
> One more, now I knew that how to commit and how much I want to commit ^^.
> Thanks and have a good day~

No worries, it always takes some time to learn the process. And I hope
you send more ath6kl patches in the future :)

I'm on vacation right, but I will take a look at your patch next week.

BTW, I have documented the process of sending patches to ath6kl here:

http://wireless.kernel.org/en/users/Drivers/ath6kl#Hacking_on_ath6kl

Hopefully that helps. Please let me know if I need to improve it.

-- 
Kalle Valo
