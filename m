From: kuznet@ms2.inr.ac.ru
Subject: Re: O/M flags against 2.6.0-test1
Date: Thu, 24 Jul 2003 18:43:44 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307241443.SAA09525@dub.inr.ac.ru>
References: <20030724.102621.89190471.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, krkumar@us.ibm.com, netdev@oss.sgi.com,
   yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org (YOSHIFUJIHideaki/=?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=)
In-Reply-To: <20030724.102621.89190471.yoshfuji@linux-ipv6.org> from "YOSHIFUJIHideaki/=?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=" at éÀÌ 24, 2003 10:26:21 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> I'm not so sure about the "array," but anyway,
> I don't think it is so ugly to use struct / offsetof.

Just write a sample of code, printing all fields of struct
and equivalent array, and you will see.

Well, I just know, that when iproute will do this, it will
cast the struct to array in any case. It is dirty, but sane at least. :-)

Alexey
