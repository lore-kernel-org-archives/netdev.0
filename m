From: Jason Lunz <lunz@falooley.org>
Subject: Re: Why was the /proc info removed from e1000 ?
Date: Thu, 30 Jan 2003 16:29:25 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <slrnb3ikqi.i0h.lunz@stoli.localnet>
References: <3E388D19.4000004@candelatech.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

greearb@candelatech.com said:
> I just noticed in the latest changelog that the /proc support was
> removed from the e1000 driver?  I always found this usefull...any
> reason why it was deleted?

shortly lower in the changelog, you'll see that the same stats are now
availble using the standard ethtool interface. I don't know whether you
need a new ethtool to make sense of the e1000 stats struct.

Jason
