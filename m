From: "David S. Miller" <davem@redhat.com>
Subject: Re: net/core/flow.c cpu handling?
Date: Sat, 1 Nov 2003 22:50:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031101225050.4de96a8b.davem@redhat.com>
References: <20031102062345.A472E2C0CD@lists.samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <20031102062345.A472E2C0CD@lists.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Very likely, the code is how it is in order to make the
2.4.x backport of this code and the 2.6.x version as
similar as humanly possible.
