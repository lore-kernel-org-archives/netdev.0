From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6 1/2]: Remove dead timer code
Date: Thu, 22 Jul 2004 17:23:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040722172314.7ae19c0c.davem@redhat.com>
References: <41005069.3030703@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41005069.3030703@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 23 Jul 2004 01:40:25 +0200
Patrick McHardy <kaber@trash.net> wrote:

> This patch removes some dead timer code left over from the
> PSCHED_JIFFIES clock source change to use get_jiffies_64().

Applied, thanks Patrick.
