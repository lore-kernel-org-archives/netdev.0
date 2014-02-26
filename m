From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/1] AX88179_178A: Add VID:DID for Lenovo OneLinkDock Gigabit LAN
Date: Wed, 26 Feb 2014 22:44:18 +0100
Message-ID: <87fvn57dn1.fsf@nemi.mork.no>
References: <87zjle6pif.fsf@nemi.mork.no>
	<20140226.154801.1466276966991949680.davem@davemloft.net>
	<87lhwx7f19.fsf@nemi.mork.no>
	<20140226.161659.2024676575146527914.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: freddy@asix.com.tw, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	Keith Packard <keithp@keithp.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140226.161659.2024676575146527914.davem@davemloft.net> (David
	Miller's message of "Wed, 26 Feb 2014 16:16:59 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:
> From: Bj=C3=B8rn Mork <bjorn@mork.no>
>
>> No, sorry for being confusing.  The patch is fine.  But Keith sent i=
t
>> first...
>
> Did I apply Keith's patch?

No, you didn't.  And when I went looking at it now, I see why: It was
posted to linux-usb and linux-kernel but not to netdev:
http://www.kernelhub.org/?msg=3D420289&p=3D2

> If not, should I apply it instead?

The patches are identical except for the author and a minor difference
in the device description string.=20

It doesn't matter to me which patch you apply, and I absolutely don't
think it's my place to tell you which patches to apply or not :-)



Bj=C3=B8rn
