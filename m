From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH] net: Don't forget pr_fmt on net_dbg_ratelimited for CONFIG_DYNAMIC_DEBUG
Date: Thu, 16 Jun 2016 10:34:50 +0200
Message-ID: <CAHmME9pp0YT1g63cv-LQagmkbqy=Atm4KxeYLM-Qv2VaHVu7Yg@mail.gmail.com>
References: <20160615091453.29609-1-Jason@zx2c4.com> <20160615.220820.479300229365061457.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, tbingham@akamai.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160615.220820.479300229365061457.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 16, 2016 at 7:08 AM, David Miller <davem@davemloft.net> wrote:
> Looks good, applied, thanks.

Great. Probably not a show stopper, but it would be nice to see this in stable.
