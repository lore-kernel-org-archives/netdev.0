From: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2003@gmx.net>
Subject: Re: forthdeth
Date: Fri, 23 Jan 2004 12:35:02 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <401106E6.2070605@gmx.net>
References: <20040123055612.78211.qmail@web80809.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Capture All <capture_all@yahoo.com>
In-Reply-To: <20040123055612.78211.qmail@web80809.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Capture All wrote:
> Hello Sir, I am going to port the nvnet driver to windows ce version.

If Windows CE is running on anything that needs nvnet, NVidia will port
the driver themselves, I'm sure.

> Could I got a copy of the src from you? Also, you mentioned there is a
> specification about the reverse engineering. Could you send it to me
> also?

Sorry, but neither I nor any of the other forcedeth developers have any
source of nvnet and we never want to have it because it would taint us.
The specification is private and will never be shared with anybody because
we do not want to get into legal trouble.

> I looked into this page, found there are some patches. Does any of the
> patch includes all the source I need? For example
> forcedeth_2_6_patch_v20.txt ?
> 
> http://www.hailfinger.org/carldani/linux/patches/forcedeth/

None of this patches will help you at all if you want to port nvnet
because forcedeth is written based on a spec that includes only nic
initialization and packet rx/tx and none of the inner workings and
structures of nvnet.

> Thanks! Blues

Sorry to disappoint you, but maybe you should ask NVidia if they release a
Windows CE version of their driver.


Carl-Daniel
-- 
http://www.hailfinger.org/
