From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: RFC: per-socket statistics on received/dropped packets
Date: Wed, 12 Jun 2002 09:32:58 +0300 (EEST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae6q7b$k3i$2@main.gmane.org>
References: <3D06E9A0.5060801@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Mark Mielke <mark@mark.mielke.cc>, <linux-kernel@vger.kernel.org>,
   <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3D06E9A0.5060801@candelatech.com>
List-Id: netdev.vger.kernel.org

On Tue, 11 Jun 2002, Ben Greear wrote:
> If they are useful to some people, and have zero performance affect on others
> (due to being a configurable kernel feature), then what is your
> complaint?

3) Added features and complexity makes it more difficult to maintain the 
kernel (you could say this is a variant of 1)

4) Patches that have only a little debugging/etc. value are probably 
useful, but mainly for a specific set of people, and this would seem to be 
best handled by external patches.
 
> 1)  General increase in #ifdef'd code.  This actually seems like
>     a pretty good argument, but I haven't seen anyone mention it
>     specifically.

Always implied from maintenance point-of-view.
 
-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords
