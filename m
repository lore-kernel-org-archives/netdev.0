From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 0/4] netns: enhance netlink interface for nsid
Date: Thu, 02 Apr 2015 10:52:33 +0200
Message-ID: <551D0351.6010003@6wind.com>
References: <1427892589-4266-1-git-send-email-nicolas.dichtel@6wind.com> <CAHA+R7N_Ah7KEDQ47nvvQDVYQDP12krc2ph0h+krex8dh7Mk2Q@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:36719 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772AbbDBIwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 04:52:36 -0400
Received: by wgra20 with SMTP id a20so78231151wgr.3
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 01:52:35 -0700 (PDT)
In-Reply-To: <CAHA+R7N_Ah7KEDQ47nvvQDVYQDP12krc2ph0h+krex8dh7Mk2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/04/2015 18:54, Cong Wang a =C3=A9crit :
> On Wed, Apr 1, 2015 at 5:49 AM, Nicolas Dichtel
> <nicolas.dichtel@6wind.com> wrote:
>>
>> The first patch has been cherry-picked from the net tree to avoid an=
y conflict
>> later.
>>
>
> You don't need to cherry-pick, you just need to wait for net merged
> into net-next,
> or simply tell DaveM your patches apply after the merge.
In fact, the goal of the cherry-pick was to inform David of that depend=
ency. I
didn't expect him to include this patch in net-next ;-)
