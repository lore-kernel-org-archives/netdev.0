From: Eugene Surovegin <ebs@ebshome.net>
Subject: Re: Asynchronous crypto layer.
Date: Sat, 30 Oct 2004 13:39:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041030203906.GC6256@gate.ebshome.net>
References: <1099030958.4944.148.camel@uganda> <1099053738.1024.104.camel@jzny.localdomain> <20041029180652.113f0f6e@zanzibar.2ka.mipt.ru> <41824D9A.3070407@logix.cz> <20041029183606.0b1a0538@zanzibar.2ka.mipt.ru> <Pine.LNX.4.61.0410291636020.25667@maxipes.logix.cz> <20041029192741.5344ad0f@zanzibar.2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Ludvig <michal@logix.cz>, netdev@oss.sgi.com,
        cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20041029192741.5344ad0f@zanzibar.2ka.mipt.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 29, 2004 at 07:27:41PM +0400, Evgeniy Polyakov wrote:
> but it was designed to be usefull only in custom MX box, 

This is not true. I coded it using Hifn PCI card plugged in 440GP eval 
board as well in P4 2.6 GHz box.

Driver isn't perfect, it's quite simple, I suspended all work on it 
because without async crypto it doesn't make a lot of sense.

> so it has some design notes that I do not agree with.

And they are (I know there are problems, just curious which ones you 
"don't agree with") ? 

--
Euege
