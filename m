From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4/2.6 PATCHES] Change some ip_fragment checks to help IPVS
Date: Sat, 11 Oct 2003 11:53:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031011115357.0c756785.davem@redhat.com>
References: <Pine.LNX.4.44.0310111956070.31823-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: wensong@linux-vs.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0310111956070.31823-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 11 Oct 2003 20:18:33 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

> # [IPV4]: ip_copy_metadata must copy the nfcache field

I can't believe we missed this, I'll definitely apply
these patches.

Thanks.

> # [IPV4]: ip_fragment should not reassemble if all frags do not have owner

This one I have to think about some more.
