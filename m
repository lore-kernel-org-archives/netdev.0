From: Wichert Akkerman <wichert@wiggy.net>
Subject: Re: ipv6 stack seems to forget to send ACKs
Date: Wed, 8 Jan 2003 18:01:39 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030108170139.GL22951@wiggy.net>
References: <20030108150201.GA30490@wiggy.net> <Pine.LNX.4.44.0301081718340.4542-100000@dns.toxicfilms.tv>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maciej Soltysiak <solt@dns.toxicfilms.tv>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0301081718340.4542-100000@dns.toxicfilms.tv>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Previously Maciej Soltysiak wrote:
> I seem to be getting better results than you, i think that it is not an
> issue of ipv6 implementation but simply the case of time sensitive
> traffic fighting with other Internet traffic over tunnels through ipv4
> networks.

Actually, I don't follow this. How could any kind of traffic shaping
result in my client not sending ACKs, which is what the tcpdump
seems to indicate? I can understand packets being dropped which
would result in retransmits, but that is not the case here.

Wichert.

(usual I'm-no-network-guru-and-might-be-misreading-things disclaimer here)

-- 
Wichert Akkerman <wichert@wiggy.net>           http://www.wiggy.net/
A random hacker
