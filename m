From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH] wlcore: wlcore should depend on MAC80211
Date: Fri, 11 May 2012 08:22:08 +0200
Message-ID: <CA+1xoqeF=101srmTNVZkP+K+SwkOr=GKS_GaMnd2G5aq95FMvA@mail.gmail.com>
References: <1336711194-26883-1-git-send-email-levinsasha928@gmail.com> <1336712810.12189.146.camel@cumari.coelho.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Luciano Coelho <coelho@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1336712810.12189.146.camel@cumari.coelho.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 11, 2012 at 7:06 AM, Luciano Coelho <coelho@ti.com> wrote:
> On Fri, 2012-05-11 at 06:39 +0200, Sasha Levin wrote:
>> wlcore can't be built if MAC80211 isn't set.
>>
>> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
>> ---
>
> Thanks for your patch, Sasha! But this change was already submitted a=
nd
> has been applied in the wl12xx.git tree. =A0I've sent a pull request =
with
> it already, but it hasn't been pulled into wireless-next and up.
>
> http://www.spinics.net/lists/linux-next/msg19910.html
> http://www.spinics.net/lists/linux-wireless/msg89583.html

Ah, no worries.

Can you consider adding the next branch of the wl12xx git tree to linux=
-next?
