From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix typo in net/ipv4/ip_input.c
Date: Fri, 12 Sep 2003 17:05:39 -0700
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20030912170539.2be84702.davem@redhat.com>
References: <20030912162729.GD8713@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, bdschuym@pandora.be,
        netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20030912162729.GD8713@conectiva.com.br>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Fri, 12 Sep 2003 13:27:30 -0300
Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:

> 	Please apply.

Applied.

This happens because of the encoding Harald uses for his
emails, when I save the email in the default way using
"Ctrl-s" in Sylpheed, I get all of those weird space and
newline characters.  I have to save it in a different way
to avoid this problem and I forgot to do that this time :(

Usually the patch fails to apply when I make this mistake,
unfortunately this time it did not.
