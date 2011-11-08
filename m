From: Christophe Aeschlimann <c.aeschlimann-5/WUhD8XThOVQ4qyx6sgCw@public.gmane.org>
Subject: Re: [PATCH 6/6] [6LoWPAN] update documentation
Date: Tue, 08 Nov 2011 15:42:30 +0100
Message-ID: <4EB93FD6.4010605@acn-group.ch>
References: <20111102162520.GA2669@avtobot.cybertron>
	<1320251754-2971-1-git-send-email-alex.bluesman.smirnov@gmail.com>
	<CALT56yOb5oZLEuHcM8dM8_gpT7mzV+9_YbsxWL3nU2N3ypCg3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <CALT56yOb5oZLEuHcM8dM8_gpT7mzV+9_YbsxWL3nU2N3ypCg3w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08.11.2011 15:32, Dmitry Eremin-Solenikov wrote:

>> +To setup 6lowpan interface you need:
>> > +1. Add IEEE802.15.4 interface and initialize PANid;
>> > +2. Add 6lowpan interface by command like:
>> > +   # ip link add link wpan0 name lowpan0 type lowpan
> Does this work with busybox ip or only with iproute2?
> =



It requires that commit :

http://git.busybox.net/busybox/commit/?id=3D6faebfa663fd008fa28f0d69d0663fe=
80675ebec

Which means a busybox release > 1.17.0

Kind Regards,

-- =

Christophe Aeschlimann

Embedded Software Engineer & IT Manager
ACN Advanced Communications Networks S.A.
2000 - Neuch=E2tel, Switzerland
Tel. +41 32 724 74 31

---------------------------------------------------------------------------=
---
RSA(R) Conference 2012
Save $700 by Nov 18
Register now
http://p.sf.net/sfu/rsa-sfdev2dev1
