From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: Implementation worries about default address selection (fwd)
Date: Thu, 17 Oct 2002 23:15:44 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210172314420.28084-100000@netcore.fi>
References: <Pine.LNX.4.44.0210160849300.9623-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <Pine.LNX.4.44.0210160849300.9623-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Oct 2002, Pekka Savola wrote:

> There were some worries about default address selection performance.
> 
> This is one person's (BSD implementer) has noticed, and it doesn't look 
> *too* bad for now.

Oh, Microsoft reported they store the source address in destination cache
for speed, which was pretty close to what Alexey suggested.

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords
