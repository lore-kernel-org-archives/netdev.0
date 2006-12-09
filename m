From: Stefan Rompf <stefan@loplof.de>
Subject: Re: [NETLINK]: Schedule removal of old macros exported to userspace
Date: Sat, 9 Dec 2006 15:58:01 +0100 (MET)
Message-ID: <200612091559.05232.stefan@loplof.de>
References: <20061208.134752.131916271.davem@davemloft.net>  <200612091249.39302.stefan@loplof.de>  <20061209125533.GO8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, drow@false.org, dwmw2@infradead.org,  joseph@codesourcery.com, netdev@vger.kernel.org, libc-alpha@sourceware.org,  akpm@osdl.org, linux-kernel@vger.kernel.org
Return-path: <libc-alpha-return-19645-glibc-alpha=m.gmane.org@sourceware.org>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061209125533.GO8693@postel.suug.ch>
Content-Disposition: inline
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

Am Samstag, 9. Dezember 2006 13:55 schrieb Thomas Graf:

> Please calm down a bit. I didn't claim that glibc should be linking to
> libnl. glibc is obviously a special case which can simply copy the existing
> macros into some internal compat header just like any other application
> that doesn't wish to use any of the libraries available.

But when even glibc needs internal compat headers to compile with the second 
kernel version that provides userspace headers, what is the long-term - even 
mid-term - perspective of make headers_install then?

Stefan
