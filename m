From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] Host Identity Protocol
Date: Tue, 15 Mar 2005 10:36:12 +0200 (EET)
Message-ID: <Pine.LNX.4.61.0503151035320.25585@netcore.fi>
References: <42369919.9010203@cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, infrahip@hiit.fi
To: Andrei Gurtov <gurtov@cs.helsinki.fi>
In-Reply-To: <42369919.9010203@cs.helsinki.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Mar 2005, Andrei Gurtov wrote:
> Please have a look at Host Identity Protocol, a better solution for secure 
> mobility and multihoming than Mobile IP.
>
> http://hipl.hiit.fi/hipl/release/kernel-patches/linux-2.6.10-hipl-0.1.patch

Please clean up the patch :).  It has tons of changes which have 
nothing to do with HIP.  Maybe it was diffed against the wrong tree?

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
