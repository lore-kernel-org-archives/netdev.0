From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 2.4.28-pre3] 3c59x: resync with 2.6
Date: Fri, 08 Oct 2004 14:32:55 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4166DD57.8060501@pobox.com>
References: <20041008121307.C14378@tuxdriver.com> <20041008191324.J17999@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, akpm@osdl.org,
        marcelo.tosatti@cyclades.com, klassert@mathematik.tu-chemnitz.de
Return-path: <netdev-bounce@oss.sgi.com>
To: Russell King <rmk+lkml@arm.linux.org.uk>
In-Reply-To: <20041008191324.J17999@flint.arm.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Russell King wrote:
> Ah, if someone's looking at the 3c59x driver then please look into the
> NWAY autonegotiation code - even maybe update it to use mii.c.


Steffen Klassert (cc'd) actually did a patch to do just that :)

	Jeff
