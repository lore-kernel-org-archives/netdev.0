From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] csiostor:T5 Firmware fix and cleanup.
Date: Tue, 27 Jan 2015 17:17:45 -0800 (PST)
Message-ID: <20150127.171745.2186381509685560794.davem@davemloft.net>
References: <1422368197-22086-1-git-send-email-praveenm@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	JBottomley@parallels.com, hch@infradead.org,
	hariprasad@chelsio.com, varun@chelsio.com
To: praveenm@chelsio.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1422368197-22086-1-git-send-email-praveenm@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Praveen Madhavan <praveenm@chelsio.com>
Date: Tue, 27 Jan 2015 19:46:37 +0530

> This patch fix is to use default firmware configuration files
> present in the adapter incase if not available in standard
> /lib/firmware/* dir. Additional cleanup is done to reuse flash
> related defines from cxgb4 header file.
> 
> Please apply over net-next since it depends on previous commit.
> 
> Signed-off-by: Praveen Madhavan <praveenm@chelsio.com>

Applied, thanks.
