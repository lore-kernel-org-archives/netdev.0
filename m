From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] can: bfin_can: switch to common
 Blackfin can header
Date: Wed, 10 Mar 2010 07:35:33 -0800 (PST)
Message-ID: <20100310.073533.34570454.davem@davemloft.net>
References: <1268150589-27123-1-git-send-email-vapier@gentoo.org>
	<4B974D38.6000501@grandegger.com>
	<8bd0f97a1003100417x6e9830dav949fd6b0511d99d0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org,
        uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
To: vapier.adi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
In-Reply-To: <8bd0f97a1003100417x6e9830dav949fd6b0511d99d0-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://blackfin.uclinux.org/mailman/options/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=unsubscribe>
List-Archive: <http://blackfin.uclinux.org/pipermail/uclinux-dist-devel>
List-Post: <mailto:uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
List-Help: <mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=help>
List-Subscribe: <https://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=subscribe>
Sender: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
Errors-To: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Mike Frysinger <vapier.adi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Wed, 10 Mar 2010 07:17:09 -0500

> On Wed, Mar 10, 2010 at 02:41, Wolfgang Grandegger wrote:
>> Mike Frysinger wrote:
>>> The MMR bits are being moved to this header, so include it.
>>>
>>> Signed-off-by: Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
>>
>> Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
>>
>>> ---
>>> note: this can be merged for 2.6.34 or 2.6.35
>>
>> Is it required to make the driver working under 2.6.34?
> 
> not for 2.6.34, but it will be for 2.6.35

I'll apply this to net-next-2.6 once I open it up, therefore.
