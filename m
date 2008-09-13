From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/4 2.6.28] cxgb3 - handle ARP replies for private iSCSI
 IP address
Date: Sat, 13 Sep 2008 15:31:44 -0400
Message-ID: <48CC1520.5070309@pobox.com>
References: <200808280421.m7S4Lw4r006465@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, michaelc@cs.wisc.edu,
	swise@opengridcomputing.com, rdreier@cisco.com, daisyc@us.ibm.com,
	wenxiong@us.ibm.com, bhua@us.ibm.com, divy@chelsio.com,
	dm@chelsio.com, leedom@chelsio.com
To: Karen Xie <kxie@chelsio.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <200808280421.m7S4Lw4r006465@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Karen Xie wrote:
> [PATCH 2/4 2.6.28] cxgb3 - handle ARP replies for private iSCSI IP address
> 
> From: Karen Xie <kxie@chelsio.com>
> 
> The accelerated iSCSI traffic uses a private IP address unknown to the OS.
> The driver has to reply to ARP requests dedicated to the private IP address.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Acked-by: Jeff Garzik <jgarzik@redhat.com>


