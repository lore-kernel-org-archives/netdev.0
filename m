From: Jim Gifford <maillist@jg555.com>
Subject: Re: [NETLINK]: Restore API compatibility of address and neighbour   bits
Date: Fri, 08 Dec 2006 09:33:50 -0800
Message-ID: <4579A1FE.1040200@jg555.com>
References: <200612062033.34754.stefan@loplof.de>  <20061207.025140.75779834.davem@davemloft.net>  <20061207105502.GJ8693@postel.suug.ch> <200612081526.12651.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,   dwmw2@infradead.org, joseph@codesourcery.com, netdev@vger.kernel.org,   libc-alpha@sourceware.org, akpm@osdl.org
Return-path: <libc-alpha-return-19632-glibc-alpha=m.gmane.org@sourceware.org>
To: Stefan Rompf <stefan@loplof.de>
In-Reply-To: <200612081526.12651.stefan@loplof.de>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

I have seen issues with some version of unifdef remove any instance of 
__KERNEL__, is the #ifndef __KERNEL__ really necessary. Has anyone 
tested to make sure the install_headers will not accidently remove this?
