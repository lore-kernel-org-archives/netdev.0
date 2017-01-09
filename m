From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Mon, 9 Jan 2017 12:08:02 -0800
Message-ID: <CA+55aFzjL6Tf7JazeZtbi9UARhqofWU8xzYm0rbdAeCsD+nMPw@mail.gmail.com>
References: <20170108.223847.1035900535306187665.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        Kalle Valo <kvalo@codeaurora.org>,
        Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170108.223847.1035900535306187665.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 8, 2017 at 7:38 PM, David Miller <davem@davemloft.net> wrote:
>
>   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net

Hmm. This still doesn't contain the rtlwifi oops fix that was posted
back before christmas.

Kalle said it was applied to the wireless-drivers tree as commit
60f59ce02785 in his tree, but it's never gotten to me.

What's up? It's three weeks later, and people are hitting the bug.

             Linus
