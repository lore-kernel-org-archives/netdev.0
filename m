From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [BK PATCH] 2.4 SCTP updates.
Date: Fri, 27 Feb 2004 16:44:14 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <403FBA2E.10907@pobox.com>
References: <Pine.LNX.4.58.0402271216200.12389@localhost.localdomain> <20040227133807.453e8d4b.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040227133807.453e8d4b.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Fri, 27 Feb 2004 12:31:18 -0800 (PST)
> Sridhar Samudrala <sri@us.ibm.com> wrote:
> 
> 
>>Thanks for fixing the MSECS_TO_JIFFIES warning.


I've re-created msec_to_jiffies() a couple times now in my own code.  It 
should be generic...

	Jeff
