From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: [PATCH] 2.4, 2.6 patchset for fealnx.c
Date: Wed, 7 Apr 2004 21:19:10 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404072116.54908.vda@port.imtp.ilyichevsk.odessa.ua>
References: <200404052217.35883.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Francois Romieu <romieu@fr.zoreil.com>,
        andreas@fjortis.info
In-Reply-To: <200404052217.35883.vda@port.imtp.ilyichevsk.odessa.ua>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 05 April 2004 22:18, Denis Vlasenko wrote:
> I almost emptied my TODO. Hurray ;)
>
> 2.4 patches are stress-tested. As before, I used UDP flood
> in extremely memory constrained box (kernel OOM killed
> several processes while I ran test). Looks ok.
>
> 2.6.5 kernel have console-related slab corruption issues
> on test machine, can't stress-test patches. Compile and boot
> tested only. Pings work.

No problems reported.

Jeff please apply.
--
vda
