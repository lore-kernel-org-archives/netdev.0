From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: [PATCH] libertas: fix possible NULL dereference
Date: Tue, 24 Nov 2015 13:02:05 +0530
Message-ID: <20151124073205.GA18880@sudip-pc>
References: <1448281922-20382-1-git-send-email-sudipm.mukherjee@gmail.com>
 <CAHp75Veb4UBKrGsODoKnZrvOZUTEm78yBvhmBRn68oZYRecdQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kalle Valo <kvalo@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	libertas-dev@lists.infradead.org,
	"open list:TI WILINK WIRELES..." <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHp75Veb4UBKrGsODoKnZrvOZUTEm78yBvhmBRn68oZYRecdQA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 24, 2015 at 01:43:38AM +0200, Andy Shevchenko wrote:
> On Mon, Nov 23, 2015 at 2:32 PM, Sudip Mukherjee
> <sudipm.mukherjee@gmail.com> wrote:
> > We were dereferencing cmd first and checking for NULL later. Lets first
> > check for NULL.
> 
> However the patch is valid due to reducing error prone part, the
> commit message seems wrong.

I will send v2 with modified commit message.

regards
sudip
