From: Kyle McMartin <kyle@debian.org>
Subject: Re: [PATCH] IPsec: add support for Twofish and Serpent
Date: Fri, 15 Aug 2003 13:34:01 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030815173401.GA3119@imladris.debian.net>
References: <20030814180857.GA4205@netppl.fi> <Pine.LNX.4.44.0308142324310.29579-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0308142324310.29579-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Aug 14, 2003 at 11:25:11PM +0300, Pekka Savola wrote:
> Very much agree.
> 
> Also, I could be missing something, but I think it takes much more to add 
> an encryption algorithm than what the patch does?!?!
> 
The algorithms were already part of the CryptoAPI. All the
patch did was simply make them accessible to IPsec, by adding
numerical IDs for ESP.

Regards,
-- 
Kyle McMartin <kyle@debian.org>
1024D/191FCD8A - 331A 9468 C04D 3A76 5C56  BA68 7EB7 92DF 191F CD8A
2048R/F515317D -   68 A9 0D 28 1B DF 8D 42  0F CC AF 98 A8 D5 A4 04
