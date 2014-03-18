From: Ben Chan <benchan@chromium.org>
Subject: Re: [PATCH 2/2] net: cdc_ncm: respect operator preferred MTU reported
 by MBIM
Date: Mon, 17 Mar 2014 21:00:06 -0700
Message-ID: <CAC5Y2nNiTX4Qo9H6R2hh3PkVAfgK3tzuq4BtoOqeCq=aa0XUtg@mail.gmail.com>
References: <CAC5Y2nN_w46FczgitbPjmXtk7q3rHpTxLddx0_GtStfzNXerXQ@mail.gmail.com>
 <87d2hkldmx.fsf@nemi.mork.no> <CAC5Y2nMdPM8w3=dgd2as5z8huL1XLPjon8wSmR-2e3=JGWtCpA@mail.gmail.com>
 <20140317.214148.2254695408331774828.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Greg Suarez <gsuarez@smithmicro.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140317.214148.2254695408331774828.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 17, 2014 at 6:41 PM, David Miller <davem@davemloft.net> wrote:
> From: Ben Chan <benchan@chromium.org>
> Date: Mon, 17 Mar 2014 17:46:27 -0700
>
>> Thanks again for the review and tip. I've submitted patch v2 to
>> address the le16_to_cpu conversion.
>
> When you update a patch from a series, you should repost the entire
> patch set, rather than just the patch which changes.
>
> This avoids any and all ambiguity of which patches go with which
> others.

Thanks for pointing that out. I've submitted the whole patch set as v3
(bumped the revision to avoid confusion).
