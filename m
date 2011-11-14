From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH series][6LoWPAN][net-next]
Date: Mon, 14 Nov 2011 08:43:35 +0300
Message-ID: <CAJmB2rDv=g2ODQivonhHA=F6KXANk1grFppgOZdUH4MRHkgzWQ@mail.gmail.com>
References: <20111110173258.GA8056@avtobot.cybertron>
	<20111114.002202.1201536915576676890.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20111114.002202.1201536915576676890.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Dear David, thank you!

Best regards,
Alexander

2011/11/14 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>:
> From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Thu, 10 Nov 2011 20:32:58 +0300
>
>> Hello all,
>>
>> The following patch series adds both major feature and minor fixes.
>> Please find detailed description in each of the patches.
>>
>> Just to summarize current development status:
>> By using MAC and PHY layers support from
>> =A0 =A0 "http://sourceforge.net/projects/linux-zigbee"
>> project now it's possible to run generic network applications (ssh, iper=
f) over
>> ieee802.15.4 network.
>>
>> iperf shows about ~40Kbits/sec for TCP
>
> All applied, thanks.
>
> In future patch submissions, please layout your Subject lines
> correctly.
>
> Everything that is inside of brackes "[]" will be removed before
> the subject line is placed at the top of the commit message. =A0So
> as-is, your commits would lack any kind of indication of where
> the code changes were occuring since the "6LowPAN" part was removed.
>
> In fact, you didn't mention 6LowPAN at all in the subject line
> of some of your commits. =A0This is unacceptable. =A0There must always
> be a subject prefix of the form "${SUBSYSTEM}: " so that what
> ends up in the commit message lets readers know the general area
> where the change was made.
>

---------------------------------------------------------------------------=
---
RSA(R) Conference 2012
Save $700 by Nov 18
Register now
http://p.sf.net/sfu/rsa-sfdev2dev1
