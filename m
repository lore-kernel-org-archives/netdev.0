From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: Re: [PATCH] tipc: link: Remove unused function
Date: Sat, 17 Jan 2015 18:18:49 +0100
Message-ID: <CAKXHbyOkeijHz_czx=7uczbeCUKk=At8-Wp0gov71bsVuPKfYg@mail.gmail.com>
References: <1421511231-14482-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<CAEUsAPaJcx-3uzH5e-wfYgicejdPt8R88hZ5X8K2gH4eXHVaVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	tipc-discussion@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Chris Rorvick <chris@rorvick.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEUsAPaJcx-3uzH5e-wfYgicejdPt8R88hZ5X8K2gH4eXHVaVw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2015-01-17 17:55 GMT+01:00 Chris Rorvick <chris@rorvick.com>:
> On Sat, Jan 17, 2015 at 10:13 AM, Rickard Strandqvist
> <rickard_strandqvist@spectrumdigital.se> wrote:
>> Remove the function tipc_link_get_max_pkt() that is not used anywhere.
>
> This is already in the next tree:
>
> commit 54fef04ad05f15984082c225fe47ce6af8ea1c5c
> Author: Ying Xue <ying.xue@windriver.com>
> Date:   Fri Jan 9 15:27:03 2015 +0800
>
>     tipc: remove unused tipc_link_get_max_pkt routine
>
>     Signed-off-by: Ying Xue <ying.xue@windriver.com>
>     Tested-by: Tero Aho <Tero.Aho@coriant.com>
>     Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>


Hi

Ok sorry, I update my linux-next clon

Kind regards
Rickard Strandqvist
