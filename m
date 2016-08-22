From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 0/3] hostap: Fine-tuning for a few functions
Date: Mon, 22 Aug 2016 18:49:24 +0300
Message-ID: <87shtwvm63.fsf@kamboji.qca.qualcomm.com>
References: <566ABCD9.1060404@users.sourceforge.net>
        <f0cd7a82-e603-6a91-0afd-33bbd1658cab@users.sourceforge.net>
        <3b3c91ad-3225-3483-bb58-fdee33bf2290@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: SF Markus Elfring <elfring@users.sourceforge.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Jouni Malinen <j@w1.fi>, LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: Arend van Spriel <arend.vanspriel@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3b3c91ad-3225-3483-bb58-fdee33bf2290@broadcom.com> (Arend van
        Spriel's message of "Sat, 20 Aug 2016 21:26:42 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arend van Spriel <arend.vanspriel@broadcom.com> writes:

> On 20-08-16 18:43, SF Markus Elfring wrote:
>> From: Markus Elfring <elfring@users.sourceforge.net>
>> Date: Sat, 20 Aug 2016 18:35:43 +0200
>> 
>> A few update suggestions were taken into account
>> from static source code analysis.
>
> Is it worth touching this old stuff especially when you are not making
> any functional changes.

On the other hand if these patches break something this might be a good
way to get feedback if someone is really using this driver ;)

But yeah, not really sure what to do with these obsolete drivers like
hostap, ray_cs and wl3501.

-- 
Kalle Valo
