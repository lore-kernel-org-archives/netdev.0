From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: Re: Acer Aspire 1524WLMi and RealTek 8169 - very slow
Date: Wed, 24 Nov 2004 19:36:41 +0000
Message-ID: <41A4E2C9.4070502@phekda.gotadsl.co.uk>
References: <41A09541.5040405@phekda.gotadsl.co.uk> <41A0F0D5.9050702@phekda.gotadsl.co.uk> <20041121205814.GA22460@electric-eye.fr.zoreil.com> <41A24F35.5080106@phekda.gotadsl.co.uk> <20041122213008.GA9618@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Me <rich@phekda.gotadsl.co.uk>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041122213008.GA9618@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

I don't know if it will help, but FreeBSD's re driver source code is here:

http://www.freebsd.org/cgi/cvsweb.cgi/src/sys/dev/re/if_re.c?only_with_tag=HEAD

Have you ever looked at that? It has some interesting comments about the 
maximum Jumbo packet length and vendor-specific registers in the 8110.

Thanks, bye, Rich =]

-- 
Richard Dawe [ http://homepages.nildram.co.uk/~phekda/richdawe/ ]

"You can't evaluate a man by logic alone."
   -- McCoy, "I, Mudd", Star Trek
