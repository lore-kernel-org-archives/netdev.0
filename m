From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: hostap: Delete an unnecessary jump label in prism2_ioctl_priv_hostapd()
Date: Mon, 26 Sep 2016 21:01:21 +0300
Message-ID: <874m52zgjy.fsf@kamboji.qca.qualcomm.com>
References: <65ed528f-7ec5-a0f2-6219-3e63a78ca0ee@users.sourceforge.net>
        <20160926150656.213D961568@smtp.codeaurora.org>
        <88d5023a-9a59-ab36-8c6c-a146cae803b5@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Jouni Malinen <j@w1.fi>, LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <88d5023a-9a59-ab36-8c6c-a146cae803b5@users.sourceforge.net> (SF
        Markus Elfring's message of "Mon, 26 Sep 2016 18:03:00 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SF Markus Elfring <elfring@users.sourceforge.net> writes:

>> 9291771 [2/3] hostap: Delete an unnecessary jump label in prism2_ioctl_priv_hostapd()
>> 9291775 [3/3] hostap: Delete unnecessary initialisations for the variable "ret"
>> 
>> Reason: The benefit is not clear.
>
> How do you think about to reduce the source code a bit at these places?

hostap is an obsolete driver, it's waste of time doing style fixes to it
as nobody maintains it anymore.

-- 
Kalle Valo
