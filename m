From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: A case AGAINST checksum offload
Date: Sat, 13 Nov 2004 12:32:23 +0100
Message-ID: <20041113113223.GA12109@electric-eye.fr.zoreil.com>
References: <Pine.LNX.4.58.0411121644150.8989@dexter.psc.edu> <1100303625.14465.631.camel@localhost> <Pine.LNX.4.58.0411121854220.8989@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Hansen <haveblue@us.ibm.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0411121854220.8989@dexter.psc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

John Heffner <jheffner@psc.edu> :
[...]
> The point is that I think it's a good idea to mitigate the effects of
> faulty hardware, especially if you can do so nearly for free.

Perhaps it could go as a new option for ethtool -t.

--
Ueimor
