From: "David S. Miller" <davem@redhat.com>
Subject: Re: Fw: [Kernel-janitors] old ioctl definitions in 2.5
Date: Mon, 15 Sep 2003 16:53:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030915165333.7b97e8f5.davem@redhat.com>
References: <20030915155415.73c5056d.davem@redhat.com>
	<200309152357.h8FNvQ73013361@death.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rddunlap@osdl.org, netdev@oss.sgi.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200309152357.h8FNvQ73013361@death.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 15 Sep 2003 16:57:26 -0700
Jay Vosburgh <fubar@us.ibm.com> wrote:

> 	My only concern is a matter of timing; we're right at the end
> of synchronizing the 2.4 and 2.6 bonding sources.  Once that's settled
> (hopefully in a few days, the last patch set for 2.4 came in this
> morning), then removing them from that header and the bonding code
> should be fine.

No problem.  Just push the change to Jeff then after you're
done merging stuff around, ok?
