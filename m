From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH v2] carl9170: Clarify kconfig text
Date: Wed, 20 Apr 2016 10:59:44 +0300
Message-ID: <87a8koiubz.fsf@kamboji.qca.qualcomm.com>
References: <20160416113312.8de2266358165182bb4b4a15@gmx.com>
	<3244016.0TmHG3E4A9@debian64>
	<87r3e2kgwy.fsf@kamboji.qca.qualcomm.com>
	<11418613.XH7h8m2RjK@debian64>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lauri Kasanen <cand@gmx.com>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <11418613.XH7h8m2RjK@debian64> (Christian Lamparter's message of
	"Mon, 18 Apr 2016 10:07:02 -0700 (PDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christian Lamparter <chunkeey@googlemail.com> writes:

> On Monday, April 18, 2016 07:42:05 PM Kalle Valo wrote:
>> Christian Lamparter <chunkeey@googlemail.com> writes:
>> 
>> > On Monday, April 18, 2016 06:45:09 PM Kalle Valo wrote:
>> >
>> >> Why even mention anything about a "special firmware" as the firmware is
>> >> already available from linux-firmware.git? 
>> >
>> > Yes and no. 1.9.6 is in linux-firmware.git. I've tried to add 1.9.9 too
>> > but that failed.
>> > <http://comments.gmane.org/gmane.linux.kernel.wireless.general/114639>
>> 
>> Rick's comment makes sense to me, better just to provide the latest
>> version. No need to unnecessary confuse the users. And if someone really
>> wants to use an older version that she can retrieve it from the git
>> history.
>
> Part of the fun here is that firmware is GPLv2. The linux-firmware.git has
> to point to or add the firmware source to their tree. They have added every
> single source file to it.... instead of "packaging" it in a tar.bz2/gz/xz
> like you normally do for release sources.
>
> If you want to read more about it:
> <http://www.spinics.net/lists/linux-wireless/msg101868.html>

Yeah, that's more work. I get that. But I'm still not understanding
what's the actual problem which prevents us from updating carl9170
firmware in linux-firmware.

-- 
Kalle Valo
