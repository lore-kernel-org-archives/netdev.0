From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] iproute2 updates
Date: 03 Mar 2005 22:49:14 -0500
Message-ID: <1109908154.1091.486.camel@jzny.localdomain>
References: <20050304023520.GD31837@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050304023520.GD31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-03-03 at 21:35, Thomas Graf wrote:
> Stephen,
> 
> You may pull the following changes from bk://tgr.bkbits.net/iproute2-tgr-fix

Other than NPROBES change, shouldnt the other changes be reflective of
whats in the kernel? This is the cost of keeping private headers. My
suggestions would be to let Steve on every major release to just sync
the header files.

cheers,
jamal

PS:- Also on you 1/2 changes - I notice one bug fix, the rest seems
cosmetic - what does that buy you? Does it make the code more readable
etc?
