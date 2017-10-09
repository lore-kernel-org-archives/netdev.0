From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v2] netlink: do not set cb_running if dump's start() errs
Date: Mon, 9 Oct 2017 19:02:15 +0200
Message-ID: <CAHmME9qvKBAF8RAiqbzP+kEn0NmqO-D3TxnAQodpt4oR9p=GYg@mail.gmail.com>
References: <CAHmME9qK84HT6DEC2Z3q-E+J8AtNSp_7GNAcjWSSsKnxX0eAkA@mail.gmail.com>
 <20171009121451.26815-1-Jason@zx2c4.com> <1507552289.26041.52.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507552289.26041.52.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 9, 2017 at 2:31 PM, Johannes Berg <johannes@sipsolutions.net> wrote:
>
> Reviewed-by: Johannes Berg <johannes@sipsolutions.net>

Thanks for the review. Hopefully this can make it into 4.13.6 and 4.14-rc5.
