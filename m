From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: 2.6.10-rc2: still no ipv6 link-local addresses
Date: Mon, 15 Nov 2004 15:34:55 -0200
Message-ID: <4198E8BF.70104@conectiva.com.br>
References: <Pine.SOC.4.61.0411151159230.3321@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Meelis Roos <mroos@linux.ee>
In-Reply-To: <Pine.SOC.4.61.0411151159230.3321@math.ut.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Can you try disabling ipv6 privacy extensions?

Meelis Roos wrote:
> I tried 2.6.10-rc2 and it still does not give lipv6 link-local address 
> to Ethernet interfaces (I tried NICs with e100 and 8139too drivers).
> 
> This is broken since 2.6.9.
> 
