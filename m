From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Fw: [Bugme-new] [Bug 4628] New: Test server hang while running
 rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4
Date: Thu, 26 May 2005 03:53:02 -0400
Message-ID: <4295805E.3060809@pobox.com>
References: <5fc59ff3050516104367a8d5cd@mail.gmail.com>	<OFB1F7DBFD.6A6514AD-ON48257004.0038A154-48257004.0038E08A@cn.ibm.com> <20050526003828.213ad052.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jian Jun He <hejianj@cn.ibm.com>, john.ronciak@intel.com,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com,
        ganesh.venkatesan@gmail.com, anton@samba.org,
        herbert@gondor.apana.org.au, linuxppc64-dev@lists.linuxppc.org.sgi.com,
        netdev@oss.sgi.com, rende@cn.ibm.com, wangjs@cn.ibm.com,
        cdlwangl@cn.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050526003828.213ad052.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> Jian Jun He <hejianj@cn.ibm.com> wrote:
> 
>>I download e100-3.4.8 and installed in the test machine (both client and
>> server). But the server still hang while running rhr (network) test. :(
> 
> 
> e100 is one of those drivers which we'd rather like to have working properly.
> 
> Can we please confirm that a) this bug is not fixed in 2.6.12-rc5 and b)
> nobody has seen a patch which fixes it?

2.6.12-rc5-git1 should have an e100 update in it, too...
