From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 5/5] schedule() bug in xfrm_lookup()
Date: Tue, 13 Jan 2004 23:27:22 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040113232722.2c04bc03.davem@redhat.com>
References: <Pine.LNX.4.44.0401131319510.25742-100000@linux-udp14999547uds>
	<Pine.LNX.4.44.0401131324340.25742-100000@linux-udp14999547uds>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, krkumar@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <krkumar@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0401131324340.25742-100000@linux-udp14999547uds>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 13 Jan 2004 13:26:21 -0800 (PST)
Krishna Kumar <krkumar@us.ibm.com> wrote:

> When xfrm_tmpl_resolve fails, schedule() before retrying. Also, cleaned
> up the set_task_* routines to use set_current_*, etc.

Applied, thanks Krishna.
