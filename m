From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH] [BRIDGE] Set features based on slave's ones
Date: Thu, 19 May 2005 15:20:44 -0500
Message-ID: <200505191520.44653.jdmason@us.ibm.com>
References: <200505191106.53136.jdmason@us.ibm.com> <20050519190032.GA19620@us.ibm.com> <20050519.122127.74747706.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: util@deuroconsult.ro, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050519.122127.74747706.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 19 May 2005 02:21 pm, David S. Miller wrote:
> From: Jon Mason <jdmason@us.ibm.com>
> Date: Thu, 19 May 2005 14:00:32 -0500
>
> > I combined my previous patch with your patch, and came up with the
> > following.  I have tested it on my system, and it works exactly the way
> > I wanted.  What do you think?
>
> Look, let's do this.  Do an initial patch that only does
> enables features possible on all devices.  Because we
> all agree that is a definite improvement from the current
> situation.
>
> Then we can discuss the relative merits of enabling features
> available on only some devices.
>
> Ok?

That is acceptable to me.
