From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: Re: Re: [PATCH 6/6] net: stmmac: revert "support future
 possible different internal phy mode"
Date: Thu, 6 Jul 2017 18:37:59 +0800
Message-ID: <CAGb2v64SY5L9gJP3ZBViskWoUJ8V_9FTdtevGPiBW2EzgSyOAQ@mail.gmail.com>
References: <20170702123159.6939-1-clabbe.montjoie@gmail.com>
 <20170702123159.6939-7-clabbe.montjoie@gmail.com> <20170706085147.GA15728@Red>
 <20170706.104514.1212305295126379350.davem@davemloft.net>
Reply-To: wens-jdAy2FN1RRM@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
To: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBBH5G7DFAKGQESZTF6AI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20170706.104514.1212305295126379350.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

Hi Corentin,

On Thu, Jul 6, 2017 at 5:45 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Thu, 6 Jul 2017 10:51:47 +0200
>
>> On Sun, Jul 02, 2017 at 02:31:59PM +0200, Corentin Labbe wrote:
>>> Since internal phy-mode is reserved for non-xMII protocol we cannot use
>>> it with dwmac-sun8i
>>> This reverts commit 1c2fa5f84683 ("net: stmmac: support future possible different internal phy mode")
>>>
>>> Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>> ---
>>
>> Hello
>>
>> This patch was left not applied but all other patch from this serie was.
>> Could you apply it, or perhaps you prefer I resend it with some "Fixes:"
>
> You never need to ask questions like this.
>
> If it's not active in my patchwork queue, you must resend.
>
> Thank you.

Your series was not applied at all. See the status on patchwork:

    http://patchwork.ozlabs.org/patch/783179/

Maxime's patch to revert all device tree changes in net-next was
applied first.

Please rebase and resend this patch for netdev (not net-next).

ChenYu
