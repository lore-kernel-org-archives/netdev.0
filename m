From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]: Disable local bh's when grabing qdisc_tree_lock in
 tc_dump_tfilter
Date: Mon, 9 Aug 2004 17:05:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040809170553.5e958dfa.davem@redhat.com>
References: <41163E5E.8060004@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41163E5E.8060004@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 08 Aug 2004 16:53:18 +0200
Patrick McHardy <kaber@trash.net> wrote:

> I missed this one when fixing locking in __qdisc_destroy.

Ok, applied.  Thanks.
