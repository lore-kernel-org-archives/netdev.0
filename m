From: "David S. Miller" <davem@redhat.com>
Subject: Re: Do you know about skb_header_pointer() ?
Date: Thu, 19 Aug 2004 07:16:18 -0700
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20040819071618.27515547.davem@redhat.com>
References: <200408190721.QAA02944@toshiba.co.jp>
	<20040819094401.GY3921@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yasuyuki.kozakai@toshiba.co.jp, kaber@trash.net, kadlec@blackhole.kfki.hu,
        kisza@securityaudit.hu, netfilter-devel@lists.netfilter.org,
        usagi-core@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040819094401.GY3921@sunbeam.de.gnumonks.org>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Thu, 19 Aug 2004 11:44:01 +0200
Harald Welte <laforge@netfilter.org> wrote:

> I personally still like Yasuyuki's implementation[1] better,

Thanks for letting me know about this after we agreed upon
skb_header_pointer() (or somthing like it) at the networking
conference _AND_ I did the full implementation for you Harald.

Or did you just learn about Ysauyuki's work recently?
