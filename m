From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.6 PATCH] ipvs - make sure the timer expires on one cpu
Date: Tue, 11 Nov 2003 16:03:20 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031111160320.29620aca.davem@redhat.com>
References: <Pine.LNX.4.44.0311110920420.1155-200000@u.domain.uli>
	<Pine.LNX.4.44.0311111004540.1176-200000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, wensong@linux-vs.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0311111004540.1176-200000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 11 Nov 2003 10:07:17 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> 	Ah, sorry. It is bad idea to set cp->timeout to 0. Please,
> better use the attached patch instead.

Applied, thanks Julian.
