From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 0/9]: TCP: The Road to Super TSO
Date: Mon, 06 Jun 2005 21:56:16 -0700
Message-ID: <42A528F0.2090208@osdl.org>
References: <20050606.210846.07641049.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, herbert@gondor.apana.org.au, jheffner@psc.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050606.210846.07641049.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'll merge these with the TCP infrastructure stuff and
send it off to Andrew. Actually, it is more of fix the TCP
infrastructure to match TSO + rc6 but you get the ida.
