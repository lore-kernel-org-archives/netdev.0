From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4/cxgb4vf/csiostor: Add T4/T5 PCI ID Table
Date: Tue, 25 Nov 2014 14:07:21 -0500 (EST)
Message-ID: <20141125.140721.1105760708655161441.davem@davemloft.net>
References: <1416884638-7582-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	JBottomley@parallels.com, hch@infradead.org, leedom@chelsio.com,
	anish@chelsio.com, nirranjan@chelsio.com, kumaras@chelsio.com,
	praveenm@chelsio.com, varun@chelsio.com
To: hariprasad@chelsio.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1416884638-7582-1-git-send-email-hariprasad@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue, 25 Nov 2014 08:33:58 +0530

> Add a new file t4_pci_id_tbl.h that contains T4/T5 PCI ID Table so that for all
> drivers that uses T4/T5 PCI functions changes can be done in one place.
> 
> checkpatch.pl script reports following error, which if tried to fix ends up in
> compilation error.
...
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thanks.
