From: Wichert Akkerman <wichert@wiggy.net>
Subject: Re: ipv6 stack seems to forget to send ACKs
Date: Thu, 9 Jan 2003 11:40:57 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030109104057.GM22951@wiggy.net>
References: <20030108224339.GO22951@wiggy.net> <Pine.LNX.4.44.0301091131370.29527-100000@dns.toxicfilms.tv>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0301091131370.29527-100000@dns.toxicfilms.tv>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Previously Maciej Soltysiak wrote:
> What other linux clients support streaming on ip6 ? patched mpg123 maybe?

The xmms patch can be adopted to work for mpg123 I suspect, I haven't
tried that.

> What XP client are you using ?

Iirc mediaplayer was used.

> Maybe it is a client issue, you say the client stops sending ACKs, maybe
> the client code is buggy.

I don't think a userspace tool can cause ACKs to stop being send.

Wichert.

-- 
Wichert Akkerman <wichert@wiggy.net>           http://www.wiggy.net/
A random hacker
