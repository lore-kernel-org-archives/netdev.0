From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v5] net: ipv6: fix code style error and warning
 of ndisc.c
Date: Sun, 21 May 2017 14:14:38 -0700
Message-ID: <1495401278.2093.12.camel@perches.com>
References: <1495328154-18653-1-git-send-email-cugyly@163.com>
         <1495382708.2093.10.camel@perches.com>
         <77510dfe-4fc7-4446-9f1a-aea52342ecd1@gmail.com>
         <20170521.125404.420857788471820007.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: cugyly@163.com, netdev@vger.kernel.org,
        Linyu.Yuan@alcatel-sbell.com.cn
To: David Miller <davem@davemloft.net>, dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0156.hostedemail.com ([216.40.44.156]:58828 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755163AbdEUVOm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 17:14:42 -0400
In-Reply-To: <20170521.125404.420857788471820007.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-05-21 at 12:54 -0400, David Miller wrote:
> From: David Ahern <dsahern@gmail.com> Date: Sun, 21 May 2017 10:17:47 -0600
> > On 5/21/17 10:05 AM, Joe Perches wrote:
> >> But really, why bother?
> >> 
> >> Just because checkpatch bleats some message doesn't
> >> mean it _has_ to be fixed.
> >> 
> >> Please strive to make the code more readable and
> >> intelligible for _humans_.  Compilers don't care.
> > 
> > +1
> > 
> > broad cleanups like this make 'git blame' harder to use to find root causes.

I don't have any issue with broad cleanups and I think
the git blame argument is overblown.

If and when broad cleanups are done, it's best if there
is some other concurrent desire to improve logic, reduce
object code size, and/or other code refactoring other
than mere whitespace changes.
