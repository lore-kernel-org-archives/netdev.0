From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [RFC] ip / ifconfig redesign
Date: Fri, 2 Dec 2005 21:59:46 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0512022159060.14136@netcore.fi>
References: <200512022253.19029.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751014AbVLBUAF@vger.kernel.org>
To: Al Boldi <a1426z@gawab.com>
In-Reply-To: <200512022253.19029.a1426z@gawab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2 Dec 2005, Al Boldi wrote:
> Consider this new approach for better address management:
> 1. Allow the definition of an address pool
> 2. Relate links to addresses
> 3. Implement to make things backward-compatible.
>
> The obvious benefit here, would be the transparent ability for apps to bind
> to addresses, regardless of the link existence.

That's called 'the loopback address', right? :)

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
