From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: linux-2.6.9 eepro100 warning
Date: Thu, 28 Oct 2004 00:38:20 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <418077BC.10806@pobox.com>
References: <200410232313.AA00003@prism.kumin.ne.jp>	<417C9A4E.3030909@pobox.com> <wxxr7nma801.fsf@nommo.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Seiichi Nakashima <nakasima@kumin.ne.jp>, linux-kernel@vger.kernel.org,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Terje Kvernes <terjekv@math.uio.no>
In-Reply-To: <wxxr7nma801.fsf@nommo.uio.no>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Terje Kvernes wrote:
> Jeff Garzik <jgarzik@pobox.com> writes:
> 
>   [ ... ]
> 
> 
>>Note that eepro100 driver will be deleted soon.
> 
> 
>   we have several systems where e100 produces netdev watchdog errors,
>   while eepro100 works without problems.  I can understand the desire
>   to migrate, but what timeframe are we looking at?  roughly
>   translated, when do I _have_ to start help debugging the e100
>   driver?  ;-)
> 
>   I can do another attempt at rolling out the e100 driver, see what
>   breaks, and try to report it around 2.6.1[01] or something like that
>   if that helps?


If there are e100 problems, report them to the maintainers so we can get 
them resolved ASAP...

INTEL PRO/100 ETHERNET SUPPORT
P:      John Ronciak
M:      john.ronciak@intel.com
P:      Ganesh Venkatesan
M:      ganesh.venkatesan@intel.com
P:      Scott Feldman
M:      scott.feldman@intel.com
W:      http://sourceforge.net/projects/e1000/
S:      Supported

(and of course netdev@oss.sgi.com as well)
