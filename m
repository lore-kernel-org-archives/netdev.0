From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFT] covert br2684 to seq_file
Date: Tue, 2 Sep 2003 21:52:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030902215258.A26380@electric-eye.fr.zoreil.com>
References: <20030902104308.08ce3fa4.shemminger@osdl.org> <20030902191433.GB67783@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
   chas williams <chas@cmf.nrl.navy.mil>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
Content-Disposition: inline
In-Reply-To: <20030902191433.GB67783@gaz.sfgoth.com>; from mitch@sfgoth.com on Tue, Sep 02, 2003 at 12:14:33PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Mitchell Blank Jr <mitch@sfgoth.com> :
[...]
> FYI - Francios Romieu has patch for converting much of net/atm/*.c to seq_file
> which will probably integrated soon (I think they're still working out
> some nits w/ Chas; not sure what the status is currently)  You probably should
> coordinate any seq_file work in the ATM code with them to avoid any duplicated
> effort.

I have sent Chas a set of patches against 2.6.0-test4 (supposedly) integrating
its comments this sunday. If it isn't merged for 2.6.0-test5, I'll send an
update to remind people that testing would help. The patches address only
net/atm/proc.c.

I have no plan for others modifications in the atm area right now as my atm
TODO is probably quite outdated.

--
Ueimor
