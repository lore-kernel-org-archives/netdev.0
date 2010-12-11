From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 03/27] Documentation/networking/igb.txt: update documentation
Date: Fri, 10 Dec 2010 21:26:57 -0800
Message-ID: <AANLkTimdr4NLYz64biQLDigGmUWciA9Du9ppL6qQqdss@mail.gmail.com>
References: <1291974667-30254-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1291974667-30254-4-git-send-email-jeffrey.t.kirsher@intel.com>
	<1291996224.11673.2.camel@bwh-desktop>
	<20101210.122149.232731880.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, davem@davemleft.org,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:33075 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827Ab0LKF05 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 00:26:57 -0500
Received: by iwn9 with SMTP id 9so6639491iwn.5
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 21:26:57 -0800 (PST)
In-Reply-To: <20101210.122149.232731880.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 10, 2010 at 12:21, David Miller <davem@davemloft.net> wrote=
:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Fri, 10 Dec 2010 15:50:24 +0000
>
>> On Fri, 2010-12-10 at 01:50 -0800, Jeff Kirsher wrote:
>>> Update Intel Wired LAN igb documentation.
>>>
>>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>> ---
>>> =C2=A0Documentation/networking/igb.txt | =C2=A0 22 ++++++++++++++++=
+++---
>>> =C2=A01 files changed, 19 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/Documentation/networking/igb.txt b/Documentation/netwo=
rking/igb.txt
>>> index ab2d718..393bdb7 100644
>>> --- a/Documentation/networking/igb.txt
>>> +++ b/Documentation/networking/igb.txt
>>> @@ -36,6 +36,7 @@ Default Value: 0
>>> =C2=A0This parameter adds support for SR-IOV. =C2=A0It causes the d=
river to spawn up to
>>> =C2=A0max_vfs worth of virtual function.
>>>
>>> +
>>> =C2=A0Additional Configurations
>>> =C2=A0=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
>>>
>>> @@ -60,7 +61,8 @@ Additional Configurations
>>> =C2=A0 =C2=A0Ethtool
>>> =C2=A0 =C2=A0-------
>>> =C2=A0 =C2=A0The driver utilizes the ethtool interface for driver c=
onfiguration and
>>> - =C2=A0diagnostics, as well as displaying statistical information.
>>> + =C2=A0diagnostics, as well as displaying statistical information.=
 The latest
>>> + =C2=A0version of Ethtool can be found at:
>>>
>>> =C2=A0 =C2=A0http://sourceforge.net/projects/gkernel.
>>
>> Please update this to:
>> http://ftp.kernel.org/pub/software/network/ethtool/
>
> Indeed.
>
> Intel folks, please address all of Ben's feedback and respin this
> pull request, thanks.
> --
>

Re-spinning the pull request now.

--=20
Cheers,
Jeff
