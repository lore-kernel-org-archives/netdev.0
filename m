From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patches] invalid nh.raw use after free
Date: Tue, 15 Jul 2003 19:17:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030715191709.1e0c6427.davem@redhat.com>
References: <Pine.LNX.4.44.0307160233540.14682-400000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0307160233540.14682-400000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Jul 2003 02:41:00 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

> 	The attached patches fix similar bug to many places (I'm not
> sure if there are more instances), where pointers remain to refer to 
> freed skbs. For 2.5 and 2.4.

Good catch, I'll apply this.

Thanks.
