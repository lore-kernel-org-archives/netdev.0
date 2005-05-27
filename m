From: Andrew Morton <akpm@osdl.org>
Subject: Re: Fw: [Bugme-new] [Bug 4628] New: Test server hang while running
 rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4
Date: Fri, 27 May 2005 01:21:01 -0700
Message-ID: <20050527012101.4b80c005.akpm@osdl.org>
References: <20050526133123.47824405.akpm@osdl.org>
	<OF8C2BEBF0.DC03FA25-ON4825700E.001E3C15-4825700E.0022793E@cn.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, rende@cn.ibm.com, ganesh.venkatesan@gmail.com,
        ganesh.venkatesan@intel.com, herbert@gondor.apana.org.au,
        jesse.brandeburg@intel.com, jgarzik@pobox.com, wangjs@cn.ibm.com,
        john.ronciak@intel.com, cdlwangl@cn.ibm.com,
        linuxppc64-dev@lists.linuxppc.org.sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jian Jun He <hejianj@cn.ibm.com>
In-Reply-To: <OF8C2BEBF0.DC03FA25-ON4825700E.001E3C15-4825700E.0022793E@cn.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jian Jun He <hejianj@cn.ibm.com> wrote:
>
> I verified the problem on 2.6.12-rc5 with mm1 patch. The test server works
>  find during the test procedure.

Great, thanks.

>  So I will close this defect in bugme.

Well we should verify that the e100 patches which Linus merged a few hours
ago did contain the fix.  So please test 2.6.12-rc5-git2, which should be
at ftp://ftp.kernel.org/pub/linux/kernel/v2.6/snapshots in ~8 hours.
