From: Seiichi Nakashima <nakasima@kumin.ne.jp>
Subject: Re: linux-2.6.9 eepro100 warning
Date: Sat, 30 Oct 2004 14:40:28 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410300540.AA00005@prism.kumin.ne.jp>
References: <wxxekjiq21q.fsf@nommo.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Netdev <netdev@oss.sgi.com>,
        Terje Kvernes <terjekv@math.uio.no>
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org
In-Reply-To: <wxxekjiq21q.fsf@nommo.uio.no>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thanks.

I update a kernel's parameter from eepro100 to PRO/100.
linux-2.6.9 work fine.

==

>
>  [ ... ]
>
>> If there are e100 problems, report them to the maintainers so we can
>> get them resolved ASAP...
>
>  I got a very nice mail from Jesse Brandeburg saying pretty much the
>  same thing...  so, I've pushed kernels for around 75 boxen over to
>  e100 today, from eepro100.  I'm not _quite_ sure when I'll have the
>  chance to boot them all, but when they do, and if they have
>  problems, I'll report back.
> 
>> INTEL PRO/100 ETHERNET SUPPORT
>> P:      John Ronciak
>> M:      john.ronciak@intel.com
>> P:      Ganesh Venkatesan
>> M:      ganesh.venkatesan@intel.com
>> P:      Scott Feldman
>> M:      scott.feldman@intel.com
>> W:      http://sourceforge.net/projects/e1000/
>> S:      Supported
>> 
>> (and of course netdev@oss.sgi.com as well)
>
>  ack.
>
>-- 
>Terje - still waiting to test hotswap SATA.   =)
>
>
--------------------------------
  Seiichi Nakashima
  Email   nakasima@kumin.ne.jp
--------------------------------
