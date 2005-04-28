From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Incorrect permissions on route flush sysctl
Date: Thu, 28 Apr 2005 12:11:46 -0700
Message-ID: <20050428121146.7b35770b.davem@davemloft.net>
References: <20050425160113.GA22919@redhat.com>
	<20050425161646.GA13778@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dave Jones <davej@redhat.com>
In-Reply-To: <20050425161646.GA13778@redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 25 Apr 2005 12:16:46 -0400
Dave Jones <davej@redhat.com> wrote:

> On Mon, Apr 25, 2005 at 12:01:13PM -0400, Dave Jones wrote:
>  > This has been brought up before.. http://lkml.org/lkml/2000/1/21/116
>  > but didnt seem to get resolved.  This morning I got someone
>  > file a bugzilla about it breaking sysctl(8).
> 
> And here's its ipv6 counterpart.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

Both applied, thanks Dave.
