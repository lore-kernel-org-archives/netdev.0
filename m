From: Patrick McHardy <kaber@trash.net>
Subject: Re: patch: introduce simple actions
Date: Wed, 23 Mar 2005 03:27:27 +0100
Message-ID: <4240D40F.107@trash.net>
References: <1111345551.1095.82.camel@jzny.localdomain>	 <423DCD8C.6030100@trash.net> <1111347345.1094.98.camel@jzny.localdomain>	 <423DD5E6.2020708@trash.net> <1111349853.1093.136.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Thomas Graf <tgraf@suug.ch>
To: hadi@znyx.com
In-Reply-To: <1111349853.1093.136.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jamal Hadi Salim wrote:
> Unfortunately code "augmentation"( as opposed to inheritance - cant
> think of a better word) is much easier to do this way. The benefit of it
> is the user gets a very simple programming interface - which is the main
> reason this was written to begin with. The standard interface exists,
> and more versed people or someone wanting to write something complex can
> go that path. At some point i would like to document all this stuff.

I don't think that a simple interface and this cleanup conflict
with each other.

> How about this:
> I submit this patch (with Thomas cleanup) and the simple action. I will
> hold onto the 4 other actions i already have some of them complete until
> you get around to moving things around and then i will redo them to
> conform. This gets it off my back and we dont have any miscommunication
> of what you are trying to do. sounds fair?

Go ahead, it will be a while before I continue with the cleanups.

Regards
Patrick
