From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH] remove unused netlink NL_EMULATE_DEV code
Date: Mon, 21 Mar 2005 10:26:11 -0800
Message-ID: <423F11C3.2020803@qualcomm.com>
References: <20050318233637.GS5389@shell0.pdx.osdl.net>	 <423B6DAE.9050803@qualcomm.com> <20050319010253.GU5389@shell0.pdx.osdl.net> <1111196899.1264.118.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@osdl.org>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
To: hadi@cyberus.ca
In-Reply-To: <1111196899.1264.118.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> 1
> On Fri, 2005-03-18 at 20:02, Chris Wright wrote:
> 
> 
>>I'd prefer that too.  What about the netlink_dev implementation itself?
>>Should it be marked obsolete?
>>
> 
> It should die - pieces of it have already been slowly disapearing.

Totally agree. Even for Ethertap it was easy to use Netlink sockets directly.

Max
