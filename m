From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: IPv6 dead in -bk11
Date: Thu, 04 Nov 2004 21:16:29 -0500
Message-ID: <418AE27D.6060609@pobox.com>
References: <20041102.225343.06193184.yoshfuji@linux-ipv6.org>	<4187A4E3.8010600@pobox.com>	<20041103.012923.102810732.yoshfuji@linux-ipv6.org> <20041104.012128.51410945.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
 <yoshfuji@linux-ipv6.org>
In-Reply-To: <20041104.012128.51410945.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / 吉藤英明 wrote:
> Sorry, this bug was introduced by my changeset:
> <http://linux.bkbits.net:8080/linux-2.5/cset@417dca81tJ4RRAxhWTbn0p6hI-1XIQ>.
> 
> David, this should fix the issue.
> Please apply.
> 
> D: Don't purge default routes by RA.
> D:
> D: Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>


ACK.  This fixed my problem.

Thanks!

	Jeff
