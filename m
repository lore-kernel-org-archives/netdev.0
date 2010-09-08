From: Matt Causey <matt.causey@gmail.com>
Subject: Re: Is via-velocity broken in 2.6.34?
Date: Tue, 7 Sep 2010 17:05:08 -0700
Message-ID: <AANLkTi=-o68GqqvOeQgEBThBJo=v2kUEy4+VDU14b3us@mail.gmail.com>
References: <AANLkTinK4VywsJ86jaC8wQjbXjzvP-z44JD3XbZbMM2a@mail.gmail.com>
	<20100907232957.GA11595@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Simon Kagstrom <simon.kagstrom@netinsight.net>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100907232957.GA11595@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 7, 2010 at 4:29 PM, Francois Romieu <romieu@fr.zoreil.com> =
wrote:
> Please Cc: netdev@vger.kernel.org

Done, cheers for that I didn't know.

>
> Matt Causey <matt.causey@gmail.com> :
> [2.6.29 -> 2.6.34 regression]
>> Attached is debug.tar. =A0It contains dmesg, config.gz, ethtool,
>> ifconfig, and lspci output. =A0I'm not sure what else to do at this
>> point. =A0Is there some debugging I can enable in the kernel to give
>> more clues as to what's gone wrong?
>
> Any chance you could bisect the regression or narrow it down a bit ?
>

I've never bisected before.  But I'll lookup some documentation and
give it a go.  :-)

> Otherwise may I assume that there is no difference in the
> userspace tools (just in case) ?
>

That's a valid assumption.  The userland was exactly the same, just
different kernel version.

--
Matt
