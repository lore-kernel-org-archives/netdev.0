From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [2.6 PATCH] ipvs - avoid NULL ptr deref in __ip_vs_get_out_rt
Date: Wed, 12 Nov 2003 02:01:34 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0311120200080.2563-100000@u.domain.uli>
References: <20031111154832.1017f57f.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <wensong@linux-vs.org>, <morpheus@theendless.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031111154832.1017f57f.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Tue, 11 Nov 2003, David S. Miller wrote:

> I assume 2.4.x does not need this fix.

	Yes, 2.4 is ok

Regards

--
Julian Anastasov <ja@ssi.bg>
