From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: 2.6.9-rc1-bk11+ and 2.6.9-rc1-mm3,4 r8169: freeze during boot
 (FIX included)
Date: Mon, 20 Sep 2004 13:59:40 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414F1A8C.10803@pobox.com>
References: <200409130035.50823.hfvogt@arcor.de> <20040916070211.GA32592@electric-eye.fr.zoreil.com> <200409161320.16526.jdmason@us.ltcfwd.linux.ibm.com> <200409171043.21772.jdmason@us.ltcfwd.linux.ibm.com> <20040917160151.GA29337@electric-eye.fr.zoreil.com> <414DF773.7060402@myrealbox.com> <20040919213952.GA32570@electric-eye.fr.zoreil.com> <414E46F1.9050309@pobox.com> <20040920071743.GA7115@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@myrealbox.com>, Hans-Frieder Vogt <hfvogt@arcor.de>,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040920071743.GA7115@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Jeff Garzik <jgarzik@pobox.com> :
> [...]
> 
>>That sounds like a bug right there...  need all the addresses set up 
>>before we turn on stuff.
> 
> 
> The description of the CPlusCmd in the 8169 datasheet includes a small note
> which suggests that this register should be set up early.
> 
> It does not cost much to try and see if it makes a difference for DAC though.

Let me know what happens :)

	Jeff
