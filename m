From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/11] Add support to FCoE offload through net_device
 (v2)
Date: Thu, 05 Mar 2009 16:10:38 -0800 (PST)
Message-ID: <20090305.161038.126200218.davem@davemloft.net>
References: <20090227220034.4987.50755.stgit.yi.zou@intel.com>
	<20090303.235725.140764281.davem@davemloft.net>
	<1236290360.5626.81.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yi.zou@intel.com, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
To: James.Bottomley@HansenPartnership.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1236290360.5626.81.camel@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 05 Mar 2009 21:59:20 +0000

> On Tue, 2009-03-03 at 23:57 -0800, David Miller wrote:
> > I am fine with these changes, they look good.
> 
> Did you want to take the four pure net pieces through your tree, and
> I'll run a postmerge tree based on your net tree, or just have me take
> them through the SCSI tree?

You can take them all via your SCSI tree.  I think it works best
that way.
