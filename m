From: Meelis Roos <mroos@linux.ee>
Subject: Re: [NET] 64 bit byte counter for 2.6.3
Date: Thu, 19 Feb 2004 10:14:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1AtjKh-0006Bz-Ee@rhn.tartu-labor>
References: <20040218101711.25dda791@dell_ss3.pdx.osdl.net>
Reply-To: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
In-Reply-To: <20040218101711.25dda791@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

SH>  * Network changes gets discussed on netdev@oss.sgi.com 
SH>  * 64 bit values are not atomic on 32 bit architectures 

Agree.

SH>  * wider values in /proc output risks breaking apps like ifconfig and netstat

This is probably not a problem here, ifconfig etc have been working fine
with non-wrapping numbers on sparc64 and other 64-bit machines.

-- 
Meelis Roos
