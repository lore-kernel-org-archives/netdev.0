From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/1] AX88179_178A: Add VID:DID for Lenovo OneLinkDock Gigabit LAN
Date: Wed, 26 Feb 2014 22:14:10 +0100
Message-ID: <87lhwx7f19.fsf@nemi.mork.no>
References: <1393404871-2248-1-git-send-email-freddy@asix.com.tw>
	<87zjle6pif.fsf@nemi.mork.no>
	<20140226.154801.1466276966991949680.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: freddy@asix.com.tw, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140226.154801.1466276966991949680.davem@davemloft.net> (David
	Miller's message of "Wed, 26 Feb 2014 15:48:01 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Bj=C3=B8rn Mork <bjorn@mork.no>
> Date: Wed, 26 Feb 2014 13:13:12 +0100
>
>> freddy@asix.com.tw writes:
>>=20
>>> From: Freddy Xin <freddy@asix.com.tw>
>>>
>>> Add VID:DID for Lenovo OneLinkDock Gigabit LAN
>>=20
>> This is the same patch Keith Packard sent, but with a slighly differ=
ent
>> description.  I take that as another proof that we should not attemp=
t to
>> describe devices in these drivers.  Describe the driver instead.
>
> Are you saying that this patch needs to be implemented differently?

No, sorry for being confusing.  The patch is fine.  But Keith sent it
first...

The other comment is more of a personal opinion on the driver style.  I=
n
any case, it's something that can be fixed up later. If at all.


Bj=C3=B8rn
