From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BK PATCH] 2.6.2 SCTP updates
Date: Mon, 9 Feb 2004 12:26:47 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040209122647.1e8df80a.davem@redhat.com>
References: <Pine.LNX.4.58.0402061649001.10831@localhost.localdomain>
	<20040206194518.56787717.davem@redhat.com>
	<Pine.LNX.4.58.0402091155070.10043@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0402091155070.10043@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 9 Feb 2004 12:01:20 -0800 (PST)
Sridhar Samudrala <sri@us.ibm.com> wrote:

> OK. I removed the SCTP specific rmem/wmem. Please do a pull again from
> 	http://linux-lksctp.bkbits.net/lksctp-2.5.work
> to get the following cset.
> 
> ChangeSet@1.1551, 2004-02-09 11:14:24-08:00, sri@us.ibm.com
>   [SCTP] Removed SCTP specific rmem/wmem sysctl's and use the global
>          rmem_default/wmem_default values for SCTP socket buffer sizes.

Pulled, thanks for following up on this Sridhar.

What is the status of synchronizing the 2.4.x SCTP sources?
